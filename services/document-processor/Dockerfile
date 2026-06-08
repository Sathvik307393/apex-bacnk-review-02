FROM node:18-alpine
WORKDIR /app
COPY services/document-processor/package*.json ./
RUN npm install
COPY services/document-processor .
COPY shared /app/shared
EXPOSE 3005
VOLUME ["/app/uploads"]
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3005/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"
CMD ["npm", "start"]
