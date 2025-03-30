# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Define build arguments
ARG PORT=3000
ARG NODE_ENV=production
ARG API_URL
ARG EMAIL_API_URL
ARG WHATSAPP_API_URL
ARG POCKETBASE_URL
ARG POCKETBASE_ADMIN_EMAIL
ARG POCKETBASE_ADMIN_PASSWORD
ARG EMAIL_HOST
ARG EMAIL_PORT
ARG EMAIL_USER
ARG EMAIL_PASSWORD
ARG EMAIL_FROM
ARG SMTP_HOST
ARG SMTP_PORT
ARG SMTP_SECURE
ARG SMTP_USER
ARG SMTP_PASSWORD
ARG GEMINI_API_KEY

# Set environment variables from build args
ENV PORT=$PORT
ENV NODE_ENV=$NODE_ENV
ENV API_URL=$API_URL
ENV EMAIL_API_URL=$EMAIL_API_URL
ENV WHATSAPP_API_URL=$WHATSAPP_API_URL
ENV POCKETBASE_URL=$POCKETBASE_URL
ENV POCKETBASE_ADMIN_EMAIL=$POCKETBASE_ADMIN_EMAIL
ENV POCKETBASE_ADMIN_PASSWORD=$POCKETBASE_ADMIN_PASSWORD
ENV EMAIL_HOST=$EMAIL_HOST
ENV EMAIL_PORT=$EMAIL_PORT
ENV EMAIL_USER=$EMAIL_USER
ENV EMAIL_PASSWORD=$EMAIL_PASSWORD
ENV EMAIL_FROM=$EMAIL_FROM
ENV SMTP_HOST=$SMTP_HOST
ENV SMTP_PORT=$SMTP_PORT
ENV SMTP_SECURE=$SMTP_SECURE
ENV SMTP_USER=$SMTP_USER
ENV SMTP_PASSWORD=$SMTP_PASSWORD
ENV GEMINI_API_KEY=$GEMINI_API_KEY

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Create .env file from environment variables
RUN echo "PORT=$PORT" > .env \
    && echo "NODE_ENV=$NODE_ENV" >> .env \
    && echo "API_URL=$API_URL" >> .env \
    && echo "EMAIL_API_URL=$EMAIL_API_URL" >> .env \
    && echo "WHATSAPP_API_URL=$WHATSAPP_API_URL" >> .env \
    && echo "POCKETBASE_URL=$POCKETBASE_URL" >> .env \
    && echo "POCKETBASE_ADMIN_EMAIL=$POCKETBASE_ADMIN_EMAIL" >> .env \
    && echo "POCKETBASE_ADMIN_PASSWORD=$POCKETBASE_ADMIN_PASSWORD" >> .env \
    && echo "EMAIL_HOST=$EMAIL_HOST" >> .env \
    && echo "EMAIL_PORT=$EMAIL_PORT" >> .env \
    && echo "EMAIL_USER=$EMAIL_USER" >> .env \
    && echo "EMAIL_PASSWORD=$EMAIL_PASSWORD" >> .env \
    && echo "EMAIL_FROM=$EMAIL_FROM" >> .env \
    && echo "SMTP_HOST=$SMTP_HOST" >> .env \
    && echo "SMTP_PORT=$SMTP_PORT" >> .env \
    && echo "SMTP_SECURE=$SMTP_SECURE" >> .env \
    && echo "SMTP_USER=$SMTP_USER" >> .env \
    && echo "SMTP_PASSWORD=$SMTP_PASSWORD" >> .env \
    && echo "GEMINI_API_KEY=$GEMINI_API_KEY" >> .env

# Copy all source files
COPY . .

# Make the fallback build script executable
RUN chmod +x scripts/fallback-build.sh

# Debug - list files and scripts
RUN echo "Listing package.json scripts:" && \
    cat package.json | grep -A 10 '"scripts"' && \
    echo "NODE_ENV: $NODE_ENV" && \
    echo "Listing project files:" && \
    ls -la && \
    echo "Listing scripts directory:" && \
    ls -la scripts/

# Build the server with explicit shell to avoid command not found errors
RUN /bin/sh -c "npm run build || npm run build:fallback"

# Production stage
FROM node:20-alpine AS runner

WORKDIR /app

# Define build arguments again for the runner stage
ARG PORT=3000
ARG NODE_ENV=production
ARG API_URL
ARG EMAIL_API_URL
ARG WHATSAPP_API_URL
ARG POCKETBASE_URL
ARG POCKETBASE_ADMIN_EMAIL
ARG POCKETBASE_ADMIN_PASSWORD
ARG EMAIL_HOST
ARG EMAIL_PORT
ARG EMAIL_USER
ARG EMAIL_PASSWORD
ARG EMAIL_FROM
ARG SMTP_HOST
ARG SMTP_PORT
ARG SMTP_SECURE
ARG SMTP_USER
ARG SMTP_PASSWORD
ARG GEMINI_API_KEY

# Set environment variables from build args
ENV PORT=$PORT
ENV NODE_ENV=$NODE_ENV
ENV API_URL=$API_URL
ENV EMAIL_API_URL=$EMAIL_API_URL
ENV WHATSAPP_API_URL=$WHATSAPP_API_URL
ENV POCKETBASE_URL=$POCKETBASE_URL
ENV POCKETBASE_ADMIN_EMAIL=$POCKETBASE_ADMIN_EMAIL
ENV POCKETBASE_ADMIN_PASSWORD=$POCKETBASE_ADMIN_PASSWORD
ENV EMAIL_HOST=$EMAIL_HOST
ENV EMAIL_PORT=$EMAIL_PORT
ENV EMAIL_USER=$EMAIL_USER
ENV EMAIL_PASSWORD=$EMAIL_PASSWORD
ENV EMAIL_FROM=$EMAIL_FROM
ENV SMTP_HOST=$SMTP_HOST
ENV SMTP_PORT=$SMTP_PORT
ENV SMTP_SECURE=$SMTP_SECURE
ENV SMTP_USER=$SMTP_USER
ENV SMTP_PASSWORD=$SMTP_PASSWORD
ENV GEMINI_API_KEY=$GEMINI_API_KEY

# Copy package files and install production dependencies
COPY package*.json ./
RUN npm ci --omit=dev

# Copy built files and configurations
COPY --from=builder /app/dist-server ./dist-server
COPY --from=builder /app/.env ./.env

# Create data directory for PocketBase
RUN mkdir -p /app/pb_data && \
    chown -R node:node /app/pb_data

# Switch to non-root user
USER node

# Expose port
EXPOSE $PORT

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost:$PORT/health || exit 1

# Start the server
CMD ["node", "dist-server/server/server.js"] 