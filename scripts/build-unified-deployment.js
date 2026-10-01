/**
 * Unified Deployment Pipeline Script
 * Builds both the Web App (Vite/React) and Flutter Web with synchronized Firebase configuration.
 */

import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const flutterDir = path.resolve(rootDir, 'flutter_app');

console.log('===========================================================');
console.log('ST. CECILIA\'S COLLEGE ALUMNI PORTAL - UNIFIED DEPLOYMENT');
console.log('===========================================================');

// 1. Verify and read shared Firebase Configuration
const firebaseConfigPath = path.resolve(rootDir, 'firebase-applet-config.json');
if (!fs.existsSync(firebaseConfigPath)) {
  console.error('❌ Error: firebase-applet-config.json not found in root directory.');
  process.exit(1);
}

const firebaseConfig = JSON.parse(fs.readFileSync(firebaseConfigPath, 'utf8'));
console.log(`✓ Firebase Project: ${firebaseConfig.projectId}`);
console.log(`✓ Firestore DB:     ${firebaseConfig.firestoreDatabaseId}`);

// 2. Synchronize configuration into Flutter Android google-services.json
const googleServicesPath = path.resolve(flutterDir, 'android', 'app', 'google-services.json');
if (fs.existsSync(googleServicesPath)) {
  const googleServices = JSON.parse(fs.readFileSync(googleServicesPath, 'utf8'));
  googleServices.project_info.project_id = firebaseConfig.projectId;
  googleServices.project_info.project_number = firebaseConfig.messagingSenderId;
  if (googleServices.client && googleServices.client[0] && googleServices.client[0].api_key) {
    googleServices.client[0].api_key[0].current_key = firebaseConfig.apiKey;
  }
  fs.writeFileSync(googleServicesPath, JSON.stringify(googleServices, null, 2));
  console.log('✓ Synchronized google-services.json with root Firebase configuration.');
}

// 3. Build the React Web App
console.log('\n--- [1/2] Building React Web Portal ---');
try {
  execSync('npm run build', { cwd: rootDir, stdio: 'inherit' });
  console.log('✓ React Web Portal built successfully to /dist');
} catch (err) {
  console.error('❌ React build failed:', err.message);
  process.exit(1);
}

// 4. Build or embed Flutter Web into /dist/flutter
console.log('\n--- [2/2] Checking Flutter Web Build ---');
let hasFlutter = false;
try {
  execSync('flutter --version', { stdio: 'ignore' });
  hasFlutter = true;
} catch {
  hasFlutter = false;
}

if (hasFlutter) {
  try {
    console.log('Compiling Flutter Web release with base-href /flutter/...');
    execSync('flutter pub get', { cwd: flutterDir, stdio: 'inherit' });
    execSync('flutter build web --release --base-href /flutter/', { cwd: flutterDir, stdio: 'inherit' });

    const flutterDistDest = path.resolve(rootDir, 'dist', 'flutter');
    if (!fs.existsSync(flutterDistDest)) {
      fs.mkdirSync(flutterDistDest, { recursive: true });
    }

    const flutterBuildWeb = path.resolve(flutterDir, 'build', 'web');
    execSync(`cp -r ${flutterBuildWeb}/* ${flutterDistDest}/`);
    console.log('✓ Flutter Web compiled and embedded into /dist/flutter');
  } catch (err) {
    console.warn('⚠️ Flutter Web build encountered an issue:', err.message);
  }
} else {
  console.log('ℹ️ Note: Flutter CLI is not installed in the server container.');
  console.log('   On your local machine with Flutter installed, run:');
  console.log('   cd flutter_app && flutter build web --release --base-href /flutter/');
  console.log('   cp -r build/web/ ../dist/flutter/');
}

console.log('\n===========================================================');
console.log('UNIFIED DEPLOYMENT BUNDLE READY FOR FIREBASE HOSTING');
console.log('Deploy with: firebase deploy --only hosting');
console.log('===========================================================');
