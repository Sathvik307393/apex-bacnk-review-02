FROM node:18-alpine
WORKDIR /app
COPY services/audit/package*.json ./
RUN npm install
COPY services/audit .
COPY shared /app/shared
EXPOSE 3006
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3006/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"
CMD ["npm", "start"]
