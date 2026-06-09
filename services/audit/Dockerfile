FROM node:18-alpine

WORKDIR /app

ENV NODE_ENV=production

COPY services/audit/package*.json ./
RUN npm install --omit=dev && npm cache clean --force

COPY services/audit .
COPY shared /app/shared

EXPOSE 3006

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3006/health', (r) => {if (r.statusCode !== 200) process.exit(1)}).on('error', () => process.exit(1))"

CMD ["node", "server.js"]


