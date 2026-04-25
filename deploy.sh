#!/bin/bash
# deploy.sh — Build Flutter Web and deploy to Firebase Hosting
# Usage: ./deploy.sh <your-vercel-url>
# Example: ./deploy.sh https://my-app.vercel.app

set -e  # exit on error

VERCEL_URL=${1:-"https://your-vercel-app.vercel.app"}
AI_ENDPOINT="${VERCEL_URL}/api/gemini-chat"

echo "🔨 Building Flutter Web..."
echo "   AI endpoint: $AI_ENDPOINT"
echo ""

flutter build web \
  --release \
  --dart-define=AI_API_ENDPOINT="$AI_ENDPOINT"

echo ""
echo "✅ Build complete → build/web"
echo ""
echo "🚀 Deploying to Firebase Hosting..."
firebase deploy --only hosting

echo ""
echo "🎉 Deployment done!"
echo "   Your app is live at: https://saksham230911186.web.app"
