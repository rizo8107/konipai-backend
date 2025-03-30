# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy all source files
COPY . .

# Build the server
RUN npm run build

# Production stage
FROM node:20-alpine AS runner

WORKDIR /app

# Copy package files and install production dependencies
COPY package*.json ./
RUN npm ci --omit=dev

# Copy built files and configurations
COPY --from=builder /app/dist-server ./dist-server
COPY --from=builder /app/.env.example ./.env
COPY --from=builder /app/server.config.ts ./

# Environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Create data directory for PocketBase
RUN mkdir -p /app/pb_data && \
    chown -R node:node /app/pb_data

# Switch to non-root user
USER node

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost:3000/health || exit 1

# Start the server
CMD ["node", "dist-server/server/server.js"] 