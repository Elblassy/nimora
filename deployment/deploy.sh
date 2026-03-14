#!/bin/bash
set -e

PROJECT_ID="${GOOGLE_CLOUD_PROJECT:-nimora-hackathon}"
REGION="${GOOGLE_CLOUD_LOCATION:-us-central1}"
BACKEND_SERVICE="nimora-backend"
FRONTEND_SERVICE="nimora-frontend"

echo "=== Deploying Nimora to Google Cloud Run ==="
echo "Project: $PROJECT_ID"
echo "Region: $REGION"

# Enable required APIs
echo "Enabling APIs..."
gcloud services enable run.googleapis.com \
  artifactregistry.googleapis.com \
  storage.googleapis.com \
  aiplatform.googleapis.com \
  --project=$PROJECT_ID

# Create GCS bucket if it doesn't exist
echo "Setting up Cloud Storage..."
gsutil mb -p $PROJECT_ID -l $REGION gs://nimora-stories 2>/dev/null || true
gsutil cors set deployment/cors.json gs://nimora-stories

# Deploy backend
echo "Deploying backend..."
gcloud run deploy $BACKEND_SERVICE \
  --source ./backend \
  --region $REGION \
  --project $PROJECT_ID \
  --allow-unauthenticated \
  --memory 1Gi \
  --timeout 120 \
  --set-env-vars "GOOGLE_CLOUD_PROJECT=$PROJECT_ID,GOOGLE_CLOUD_LOCATION=$REGION,GCS_BUCKET_NAME=nimora-stories"

# Get backend URL
BACKEND_URL=$(gcloud run services describe $BACKEND_SERVICE --region $REGION --project $PROJECT_ID --format='value(status.url)')
echo "Backend deployed at: $BACKEND_URL"

# Update frontend API URL
echo "Updating frontend API URL..."
sed -i.bak "s|http://localhost:8000|$BACKEND_URL|g" frontend/lib/utils/constants.dart
rm -f frontend/lib/utils/constants.dart.bak

# Deploy frontend
echo "Deploying frontend..."
gcloud run deploy $FRONTEND_SERVICE \
  --source ./frontend \
  --region $REGION \
  --project $PROJECT_ID \
  --allow-unauthenticated

FRONTEND_URL=$(gcloud run services describe $FRONTEND_SERVICE --region $REGION --project $PROJECT_ID --format='value(status.url)')
echo ""
echo "=== Deployment Complete ==="
echo "Frontend: $FRONTEND_URL"
echo "Backend:  $BACKEND_URL"
echo "Health:   $BACKEND_URL/api/health"
