const { app } = require('@azure/functions');
const { ServiceBusClient } = require('@azure/service-bus');
const { BlobServiceClient } = require('@azure/storage-blob');
const pdfParse = require('pdf-parse');
const Tesseract = require('tesseract.js');

const connectionString = process.env.KycStorage;
const rawContainerName = process.env.RAW_CONTAINER_NAME || 'kyc-documents';
const processedContainerName =
  process.env.PROCESSED_CONTAINER_NAME || 'processed-and-validated-container';
const serviceBusConnection = process.env.ServiceBusConnection;
const resultQueueName =
  process.env.SERVICE_BUS_RESULT_QUEUE || 'kyc-processing-results';
const serviceBusClient = serviceBusConnection
  ? new ServiceBusClient(serviceBusConnection)
  : null;
const resultSender = serviceBusClient
  ? serviceBusClient.createSender(resultQueueName)
  : null;

function decodeMetadata(value, fallback) {
  if (!value) return fallback;
  try {
    return decodeURIComponent(value);
  } catch {
    return value;
  }
}

async function publishResult(result, context) {
  if (!resultSender) {
    context.warn('ServiceBusConnection is missing; database status will remain pending.');
    return;
  }

  await resultSender.sendMessages({
    body: {
      type: 'KYC_DOCUMENT_PROCESSED',
      ...result
    },
    contentType: 'application/json',
    subject: result.status
  });
}

function findDocumentNumber(text, documentType) {
  const normalized = text.toUpperCase();

  if (documentType === 'AADHAAR') {
    const match = normalized.match(/(?:\d{4}\s*){3}/);
    return match ? match[0].replace(/\s/g, '') : null;
  }

  if (documentType === 'PAN') {
    return normalized.match(/[A-Z]{5}[0-9]{4}[A-Z]/)?.[0] || null;
  }

  if (documentType === 'PASSPORT') {
    return normalized.match(/[A-Z][0-9]{7}/)?.[0] || null;
  }

  return documentType === 'PHOTO' ? 'PHOTO_ACCEPTED' : null;
}

async function extractText(blob, contentType) {
  if (contentType === 'application/pdf') {
    const parsed = await pdfParse(blob);
    return parsed.text || '';
  }

  if (contentType?.startsWith('image/')) {
    const result = await Tesseract.recognize(blob, 'eng');
    return result.data.text || '';
  }

  throw new Error(`Unsupported content type: ${contentType || 'unknown'}`);
}

async function processKycDocument(blob, context) {
  if (!connectionString) {
    throw new Error('KycStorage application setting is missing.');
  }

  const blobName = context.triggerMetadata.name;
  const blobServiceClient =
    BlobServiceClient.fromConnectionString(connectionString);
  const rawBlobClient = blobServiceClient
    .getContainerClient(rawContainerName)
    .getBlobClient(blobName);
  const processedContainerClient =
    blobServiceClient.getContainerClient(processedContainerName);

  await processedContainerClient.createIfNotExists();

  const properties = await rawBlobClient.getProperties();
  const metadata = properties.metadata || {};
  const contentType = properties.contentType || 'application/octet-stream';
  const documentType = decodeMetadata(
    metadata.documenttype,
    'DOCUMENT'
  ).toUpperCase();
  const resultBlobName = `${blobName}.result.json`;
  const resultBlobClient =
    processedContainerClient.getBlockBlobClient(resultBlobName);

  if (await resultBlobClient.exists()) {
    const existingResult = JSON.parse(
      (await resultBlobClient.downloadToBuffer()).toString('utf8')
    );
    await publishResult(existingResult, context);
    context.log(`Republished result for already processed blob: ${blobName}`);
    return;
  }

  let status = 'Invalid';
  let reason;
  let extractedNumber = null;

  try {
    const extractedText = await extractText(blob, contentType);
    extractedNumber = findDocumentNumber(extractedText, documentType);
    status = extractedNumber ? 'Verified' : 'Invalid';
    reason = extractedNumber
      ? `${documentType} document passed validation.`
      : `${documentType} identifier was not found in the document.`;
  } catch (error) {
    reason = error.message;
    context.error(`Processing failed for ${blobName}: ${error.message}`);
  }

  const processedBlobClient =
    processedContainerClient.getBlockBlobClient(blobName);
  await processedBlobClient.uploadData(blob, {
    blobHTTPHeaders: { blobContentType: contentType },
    metadata: {
      ...metadata,
      validationstatus: status,
      processedatutc: new Date().toISOString()
    }
  });

  const result = {
    sourceContainer: rawContainerName,
    sourceBlob: blobName,
    processedContainer: processedContainerName,
    processedBlob: blobName,
    status,
    reason,
    documentType,
    extractedNumber,
    userId: metadata.userid || null,
    originalName: decodeMetadata(metadata.originalname, blobName),
    processedAtUtc: new Date().toISOString()
  };

  const resultBody = JSON.stringify(result, null, 2);
  await resultBlobClient.upload(resultBody, Buffer.byteLength(resultBody), {
    blobHTTPHeaders: { blobContentType: 'application/json' }
  });

  await publishResult(result, context);

  context.log(`Processed ${blobName}: ${status}`);
}

app.storageBlob('processKycDocument', {
  path: `${rawContainerName}/{name}`,
  connection: 'KycStorage',
  handler: processKycDocument
});
