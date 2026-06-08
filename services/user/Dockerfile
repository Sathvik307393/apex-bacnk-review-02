FROM node:18-alpine

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

ENV NODE_ENV=production

COPY --chown=appuser:appgroup services/user/package*.json ./
RUN npm ci --only=production && npm cache clean --force

COPY --chown=appuser:appgroup services/user .
COPY --chown=appuser:appgroup shared /app/shared

USER appuser

EXPOSE 3002

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3002/health', (r) => {if (r.statusCode !== 200) process.exit(1)}).on('error', () => process.exit(1))"

CMD ["node", "server.js"]
