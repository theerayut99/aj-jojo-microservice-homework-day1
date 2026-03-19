FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# --- Production ---
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY --from=builder /app/dist ./dist

# Factor 3: Config via environment variables
ENV HOST=0.0.0.0
ENV PORT=3000
ENV LOG_LEVEL=info
ENV NODE_ENV=production

EXPOSE 3000

# Factor 9: Graceful shutdown
STOPSIGNAL SIGTERM

CMD ["node", "dist/main"]
