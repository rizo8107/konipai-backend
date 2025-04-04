import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs';

// Log current environment mode
console.log('Current NODE_ENV:', process.env.NODE_ENV);

// In browser environment, we don't need to load .env file as Vite handles it
// Only run dotenv in Node.js environment
if (typeof process !== 'undefined' && process.env) {
  try {
    // Try loading from current directory
    const result = dotenv.config();
    if (result.error) {
      console.warn('Error loading .env file:', result.error.message);
      
      // Try loading from root directory as fallback
      const rootEnvPath = path.resolve(process.cwd(), '.env');
      if (fs.existsSync(rootEnvPath)) {
        console.log(`Trying to load .env from: ${rootEnvPath}`);
        dotenv.config({ path: rootEnvPath });
      }
      
      // Create a minimal .env file with defaults if nothing exists
      if (!fs.existsSync('.env') && !fs.existsSync(rootEnvPath)) {
        console.log('Creating minimal .env file with defaults');
        const defaultEnv = `
VITE_API_URL=http://localhost:3000/api
VITE_EMAIL_API_URL=http://localhost:3000/email-api
VITE_WHATSAPP_API_URL=https://backend-whatsappapi.7za6uc.easypanel.host
VITE_POCKETBASE_URL=https://backend-pocketbase.7za6uc.easypanel.host
POCKETBASE_ADMIN_EMAIL=nnirmal7107@gmail.com
POCKETBASE_ADMIN_PASSWORD=Kamala@7107
`;
        fs.writeFileSync('.env', defaultEnv);
        dotenv.config();
      }
    } else {
      console.log('Successfully loaded .env file');
    }
  } catch (error) {
    console.error('Error during environment loading:', error);
  }
}

// Define a function to get environment variables with a fallback
export function getEnv(key: string, defaultValue: string = ''): string {
  if (typeof process !== 'undefined' && process.env) {
    // Node.js environment
    const value = process.env[key] || defaultValue;
    return value;
  }
  // Fallback if process.env is not available
  return defaultValue;
}

// Server-side environment variables with hardcoded defaults as fallback
export const SERVER_ENV = {
  API_URL: getEnv('API_URL', 'http://localhost:3000/api'),
  EMAIL_API_URL: getEnv('EMAIL_API_URL', 'http://localhost:3000/email-api'),
  GEMINI_API_KEY: getEnv('GEMINI_API_KEY', ''),
  POCKETBASE_URL: getEnv('POCKETBASE_URL', 'https://backend-pocketbase.7za6uc.easypanel.host'),
  POCKETBASE_ADMIN_EMAIL: getEnv('POCKETBASE_ADMIN_EMAIL', 'nnirmal7107@gmail.com'),
  POCKETBASE_ADMIN_PASSWORD: getEnv('POCKETBASE_ADMIN_PASSWORD', 'Kamala@7107'),
  WHATSAPP_API_URL: getEnv('WHATSAPP_API_URL', 'https://backend-whatsappapi.7za6uc.easypanel.host')
};

// Debug log
console.log('Loaded SERVER_ENV:', {
  API_URL: SERVER_ENV.API_URL,
  EMAIL_API_URL: SERVER_ENV.EMAIL_API_URL,
  WHATSAPP_API_URL: SERVER_ENV.WHATSAPP_API_URL,
  POCKETBASE_URL: SERVER_ENV.POCKETBASE_URL
});