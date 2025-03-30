#!/bin/sh
# Fallback build script for cases where the main build fails

set -e
echo "Running fallback build script..."

# Ensure directories exist
mkdir -p dist-server/server

# Create a minimal server.js file
cat > dist-server/server/server.js << 'EOF'
/**
 * Minimal fallback server implementation
 * Created by fallback-build.sh
 */
import express from 'express';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'ok',
    message: 'Fallback server running',
    environment: process.env.NODE_ENV,
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'Fallback server is running!',
    environment: process.env.NODE_ENV,
    port: PORT,
    apiUrl: process.env.API_URL,
    emailApiUrl: process.env.EMAIL_API_URL,
    whatsappApiUrl: process.env.WHATSAPP_API_URL,
    timestamp: new Date().toISOString()
  });
});

// Echo environment endpoint
app.get('/environment', (req, res) => {
  res.json({
    NODE_ENV: process.env.NODE_ENV,
    API_URL: process.env.API_URL,
    EMAIL_API_URL: process.env.EMAIL_API_URL,
    WHATSAPP_API_URL: process.env.WHATSAPP_API_URL,
    POCKETBASE_URL: process.env.POCKETBASE_URL,
    PORT: process.env.PORT
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Fallback server running on port ${PORT}`);
  console.log('Environment:', process.env.NODE_ENV);
  console.log('API URL:', process.env.API_URL);
  console.log('Email API URL:', process.env.EMAIL_API_URL);
  console.log('WhatsApp API URL:', process.env.WHATSAPP_API_URL);
});
EOF

# Create a minimal index.js that just imports server.js
cat > dist-server/server/index.js << 'EOF'
/**
 * Index entry point - redirects to server.js
 */
import './server.js';
EOF

echo "Fallback build completed successfully!"
echo "Created minimal server at dist-server/server/server.js"
echo "Contents of dist-server:"
ls -la dist-server
echo "Contents of dist-server/server:"
ls -la dist-server/server 