FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY services/api-gateway/package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY services/api-gateway .

# Copy shared modules
COPY shared /app/shared

# Expose port (will be overridden by compose)
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Start application
CMD ["npm", "start"]
