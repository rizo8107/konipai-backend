# Konipai CRM Backend Server

Backend server for the Konipai CRM system, built with Node.js, Express, and TypeScript.

## Features

- Email service integration with SMTP support
- WhatsApp messaging integration
- PocketBase database integration
- Health monitoring endpoints
- Docker containerization
- Easypanel deployment support

## Prerequisites

- Node.js 20 or higher
- npm 9 or higher
- Docker (for containerization)

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd konipai-backend-server
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create environment file:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` with your configuration.

## Development

Start the development server:
```bash
npm run dev
```

## Building

Build the project:
```bash
npm run build
```

## Production

Start the production server:
```bash
npm run start
```

## Docker

Build the Docker image:
```bash
docker build -t konipai-backend-server .
```

Run the container:
```bash
docker run -p 3000:3000 --env-file .env konipai-backend-server
```

## Easypanel Deployment

1. Set up environment variables in Easypanel
2. Deploy using the provided Dockerfile
3. Configure health checks at `/health` endpoint
4. Set up volumes for PocketBase data persistence

## API Endpoints

- `GET /health` - Health check endpoint
- `GET /` - Root endpoint
- `POST /email-api/*` - Email service endpoints
- Additional endpoints documented in the code

## Environment Variables

See `.env.example` for all required environment variables.

## License

Proprietary - All rights reserved

## Support

For support, contact support@konipai.in 