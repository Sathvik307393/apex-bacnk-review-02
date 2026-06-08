FROM node:18-alpine

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Set production environment
ENV NODE_ENV=production

# Copy package files and install production dependencies only
COPY --chown=appuser:appgroup services/api-gateway/package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copy source code and shared modules
COPY --chown=appuser:appgroup services/api-gateway .
COPY --chown=appuser:appgroup shared /app/shared

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) process.exit(1)}).on('error', () => process.exit(1))"

# Start application
CMD ["node", "server.js"]
