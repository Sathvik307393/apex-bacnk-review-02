FROM node:18-alpine

WORKDIR /app

COPY services/auth/package*.json ./
RUN npm install

COPY services/auth . 
COPY shared /app/shared

EXPOSE 3001

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3001/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

CMD ["npm", "start"]
