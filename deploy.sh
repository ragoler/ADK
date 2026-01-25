#!/bin/bash
set -e

# Usage:
#   ./deploy.sh [OPTIONS]
#
# Options:
#   --local             Build the Docker image locally instead of using Cloud Build.
#                       Requires Docker to be installed and the daemon running.
#   -e NAME=VALUE       Pass environment variables to the build process as build arguments.
#                       Can be used multiple times. (e.g., -e KEY1=VAL1 -e KEY2=VAL2)
#   --delete            Teardown all resources created by this script.
#   --help              Show this help message.
#
# Examples:
#   ./deploy.sh         # Default (Cloud Build)
#   ./deploy.sh --local # Build locally
#   ./deploy.sh --delete # Teardown

# Default Configuration
PROJECT_ID=$(gcloud config get-value project)
REGION="us-west1"
CLUSTER_NAME="adk-cluster"
REPO_NAME="adk-repo"
IMAGE_NAME="adk-web"
TAG="latest"
GSA_NAME="adk-service-account"
KSA_NAME="adk-ksa"
NAMESPACE="default"

# Internal variables
LOCAL_BUILD=false
DELETE_RESOURCES=false
SKIP_INFRA=false
ENV_VARS=()

# Argument parsing
while [[ $# -gt 0 ]]; do
  case $1 in
    --local)
      LOCAL_BUILD=true
      shift
      ;;
    --no-infra)
      SKIP_INFRA=true
      shift
      ;;
    -e)
      if [[ -n "$2" ]]; then
        ENV_VARS+=(--build-arg "$2")
        shift 2
      else
        echo "Error: -e requires an argument (NAME=VALUE)."
        exit 1
      fi
      ;;
    --delete)
      DELETE_RESOURCES=true
      shift
      ;;
    --help)
      cat <<EOF
Usage: ./deploy.sh [OPTIONS]

Options:
  --local             Build the Docker image locally instead of using Cloud Build.
                      Requires Docker to be installed and the daemon running.
  --no-infra          Skip infrastructure setup (APIs, IAM, Cluster, Repo, Secrets).
                      Only build and deploy the application.
  -e NAME=VALUE       Pass environment variables to the build process as build arguments.
                      Can be used multiple times (e.g., -e KEY1=VAL1 -e KEY2=VAL2).
  --delete            Teardown all resources created by this script.
  --help              Show this help message.

Examples:
  ./deploy.sh            # Default (Cloud Build + Infra)
  ./deploy.sh --no-infra # Build and Deploy only
  ./deploy.sh --local    # Build locally + Infra
  ./deploy.sh --delete   # Teardown
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information."
      exit 1
      ;;
  esac
done

PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
COMPUTE_SERVICE_ACCOUNT="$PROJECT_NUMBER-compute@developer.gserviceaccount.com"
CURRENT_USER=$(gcloud config get-value account)
GSA_EMAIL="$GSA_NAME@$PROJECT_ID.iam.gserviceaccount.com"


# --- Teardown Logic ---
# --- Teardown Logic ---
if [ "$DELETE_RESOURCES" == "true" ]; then
  echo "Deleting all cloud resources..."
  
  echo "Getting cluster credentials to ensure kubectl is targeting the right cluster..."
  if gcloud container clusters get-credentials $CLUSTER_NAME --region=$REGION; then
    echo "Deleting Kubernetes resources..."
    kubectl delete -f kubernetes.yaml --ignore-not-found=true

    echo "Deleting Kubernetes secret..."
    kubectl delete secret adk-secrets --ignore-not-found=true
  else
    echo "Cluster not found, skipping Kubernetes resource deletion."
  fi

  echo "Deleting GKE cluster..."
  gcloud container clusters delete $CLUSTER_NAME --region=$REGION --quiet || echo "GKE cluster not found or already deleted."
  
  echo "Removing IAM policy bindings..."
  
  gcloud projects remove-iam-policy-binding $PROJECT_ID --member="serviceAccount:$COMPUTE_SERVICE_ACCOUNT" --role="roles/storage.admin" --condition=None --quiet || echo "IAM binding for storage.admin not found."
  gcloud projects remove-iam-policy-binding $PROJECT_ID --member="serviceAccount:$COMPUTE_SERVICE_ACCOUNT" --role="roles/storage.objectViewer" --condition=None --quiet || echo "IAM binding for storage.objectViewer not found."
  gcloud projects remove-iam-policy-binding $PROJECT_ID --member="serviceAccount:$COMPUTE_SERVICE_ACCOUNT" --role="roles/artifactregistry.reader" --condition=None --quiet || echo "IAM binding for artifactregistry.reader not found."
  gcloud projects remove-iam-policy-binding $PROJECT_ID --member="serviceAccount:$COMPUTE_SERVICE_ACCOUNT" --role="roles/logging.logWriter" --condition=None --quiet || echo "IAM binding for logging.logWriter not found."
  gcloud projects remove-iam-policy-binding $PROJECT_ID --member="user:$CURRENT_USER" --role="roles/storage.objectViewer" --condition=None --quiet || echo "IAM binding for user storage.objectViewer not found."
  gcloud projects remove-iam-policy-binding $PROJECT_ID --member="serviceAccount:$GSA_EMAIL" --role="roles/aiplatform.user" --condition=None --quiet || echo "IAM binding for aiplatform.user not found."
  gcloud projects remove-iam-policy-binding $PROJECT_ID --member="serviceAccount:$GSA_EMAIL" --role="roles/discoveryengine.admin" --condition=None --quiet || echo "IAM binding for discoveryengine.admin not found."
  gcloud iam service-accounts remove-iam-policy-binding $GSA_EMAIL --role="roles/iam.workloadIdentityUser" --member="serviceAccount:$PROJECT_ID.svc.id.goog[$NAMESPACE/$KSA_NAME]" --quiet || echo "IAM binding for workloadIdentityUser not found."

  echo "Deleting Google Service Account..."
  gcloud iam service-accounts delete $GSA_EMAIL --quiet || echo "GSA not found or already deleted."

  echo "Deleting Artifact Registry repository..."
  gcloud artifacts repositories delete $REPO_NAME --location=$REGION --quiet || echo "Artifact Registry repository not found or already deleted."
  
  echo "Deleting staging bucket..."
  STAGING_BUCKET="gs://${PROJECT_ID}-build-staging"
  gsutil rm -r $STAGING_BUCKET || echo "Staging bucket not found or already deleted."

  echo "Deletion complete."
  exit 0
fi


echo "Using Project ID: $PROJECT_ID"

if [ "$SKIP_INFRA" == "false" ]; then
    # 1. Enable APIs
    echo "Enabling required APIs..."
    gcloud services enable container.googleapis.com \
        artifactregistry.googleapis.com \
        cloudbuild.googleapis.com \
        aiplatform.googleapis.com

    # 2. Grant Storage Admin to the default compute service account
    # This is often needed for Cloud Build to access the GCS source buckets
    PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
    COMPUTE_SERVICE_ACCOUNT="$PROJECT_NUMBER-compute@developer.gserviceaccount.com"
    echo "Granting Storage Admin to $COMPUTE_SERVICE_ACCOUNT..."
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$COMPUTE_SERVICE_ACCOUNT" \
        --role="roles/storage.admin"

    echo "Granting Storage Object Viewer to $COMPUTE_SERVICE_ACCOUNT..."
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$COMPUTE_SERVICE_ACCOUNT" \
        --role="roles/storage.objectViewer"

    echo "Granting Artifact Registry Reader to $COMPUTE_SERVICE_ACCOUNT..."
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$COMPUTE_SERVICE_ACCOUNT" \
        --role="roles/artifactregistry.reader"

    echo "Granting Logs Writer to $COMPUTE_SERVICE_ACCOUNT..."
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$COMPUTE_SERVICE_ACCOUNT" \
        --role="roles/logging.logWriter"

    # Grant Artifact Registry Writer to both Cloud Build Service Account variants
    CLOUD_BUILD_SA_LEGACY="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
    CLOUD_BUILD_SA_MODERN="service-${PROJECT_NUMBER}@gcp-sa-cloudbuild.iam.gserviceaccount.com"

    echo "Granting Artifact Registry Writer to Cloud Build service accounts at project level..."
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$CLOUD_BUILD_SA_LEGACY" \
        --role="roles/artifactregistry.writer" --quiet > /dev/null || true

    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$CLOUD_BUILD_SA_MODERN" \
        --role="roles/artifactregistry.writer" --quiet > /dev/null || true

        --location=$REGION \
        --member="serviceAccount:$CLOUD_BUILD_SA_MODERN" \
        --role="roles/artifactregistry.writer" --quiet > /dev/null || true

    echo "Waiting 30 seconds for IAM permissions to propagate..."
    sleep 30


    # 3. Create Artifact Registry repository if it doesn't exist
    if ! gcloud artifacts repositories describe $REPO_NAME --location=$REGION &>/dev/null; then
        echo "Creating Artifact Registry repository..."
        gcloud artifacts repositories create $REPO_NAME \
            --repository-format=docker \
            --location=$REGION \
            --description="Docker repository for ADK"
    else
        echo "Artifact Registry repository already exists."
    fi

    # 4. Create GKE Autopilot cluster if it doesn't exist
    if ! gcloud container clusters describe $CLUSTER_NAME --region=$REGION &>/dev/null; then
        echo "Creating GKE Autopilot cluster..."
        gcloud container clusters create-auto $CLUSTER_NAME \
            --region=$REGION
    else
        echo "GKE cluster already exists."
    fi
fi

# 5. Get GKE credentials (Always needed to ensure kubectl context is correct)
echo "Getting GKE credentials..."
gcloud container clusters get-credentials $CLUSTER_NAME --region=$REGION

if [ "$SKIP_INFRA" == "false" ]; then
    # 6. Create Kubernetes Secret from .env
    echo "Creating/Updating Kubernetes Secret from .env..."
    # Create a temporary .env to ensure GOOGLE_CLOUD_PROJECT matches the current project
    cp .env .env.tmp
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i "" "s/GOOGLE_CLOUD_PROJECT=.*/GOOGLE_CLOUD_PROJECT=$PROJECT_ID/" .env.tmp
    else
        sed -i "s/GOOGLE_CLOUD_PROJECT=.*/GOOGLE_CLOUD_PROJECT=$PROJECT_ID/" .env.tmp
    fi
    kubectl create secret generic adk-secrets --from-env-file=.env.tmp --dry-run=client -o yaml | kubectl apply -f -
    rm .env.tmp

    # 7. Setup Workload Identity (IAM)
    if ! gcloud iam service-accounts describe $GSA_EMAIL &>/dev/null; then
        echo "Creating Google Service Account $GSA_NAME..."
        gcloud iam service-accounts create $GSA_NAME --display-name="ADK Service Account"
        
        echo "Waiting for GSA to propagate..."
        sleep 10
        
        echo "Binding Vertex AI and Search roles to GSA..."
        gcloud projects add-iam-policy-binding $PROJECT_ID \
            --member="serviceAccount:$GSA_EMAIL" \
            --role="roles/aiplatform.user"
        gcloud projects add-iam-policy-binding $PROJECT_ID \
            --member="serviceAccount:$GSA_EMAIL" \
            --role="roles/discoveryengine.admin"
    else
        echo "Google Service Account $GSA_NAME already exists."
        # Ensure bindings exist anyway in case they failed partially
        gcloud projects add-iam-policy-binding $PROJECT_ID \
            --member="serviceAccount:$GSA_EMAIL" \
            --role="roles/aiplatform.user" --quiet > /dev/null
        gcloud projects add-iam-policy-binding $PROJECT_ID \
            --member="serviceAccount:$GSA_EMAIL" \
            --role="roles/discoveryengine.admin" --quiet > /dev/null
    fi

    # Create Kubernetes Service Account
    if ! kubectl get sa $KSA_NAME &>/dev/null; then
        echo "Creating Kubernetes Service Account $KSA_NAME..."
        kubectl create serviceaccount $KSA_NAME --namespace $NAMESPACE
    else
        echo "Kubernetes Service Account $KSA_NAME already exists."
    fi

    # Bind GSA to KSA (Workload Identity)
    echo "Binding GSA to KSA via Workload Identity..."
    gcloud iam service-accounts add-iam-policy-binding $GSA_EMAIL \
        --role="roles/iam.workloadIdentityUser" \
        --member="serviceAccount:$PROJECT_ID.svc.id.goog[$NAMESPACE/$KSA_NAME]"

    kubectl annotate serviceaccount $KSA_NAME --namespace $NAMESPACE \
        iam.gke.io/gcp-service-account=$GSA_EMAIL --overwrite
fi

# 8. Build and Push image
IMAGE_URL="$REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$IMAGE_NAME:$TAG"

if [ "$LOCAL_BUILD" == "true" ]; then
    echo "Building and pushing image to $IMAGE_URL using local Docker..."
    
    if ! command -v docker &> /dev/null; then
        echo "Error: Docker is not installed. Local build requires Docker."
        exit 1
    fi

    # Try to detect local PIP_INDEX_URL from venv
    DETECTED_INDEX=$(.venv/bin/pip config get global.index-url 2>/dev/null || true)
    if [ -n "$DETECTED_INDEX" ]; then
        echo "Detected local pip index: $DETECTED_INDEX"
        ENV_VARS+=(--build-arg "PIP_INDEX_URL=$DETECTED_INDEX")
    fi

    echo "Configuring Docker for Artifact Registry..."
    gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

    echo "Running local Docker build (using --network host for DNS stability)..."
    docker build --network host "${ENV_VARS[@]}" -t $IMAGE_URL .
    
    echo "Pushing image to Artifact Registry..."
    docker push $IMAGE_URL
else
    echo "Building and pushing image to $IMAGE_URL using Cloud Build..."

    # FIX: Create a dedicated staging bucket in your region
    STAGING_BUCKET="gs://${PROJECT_ID}-build-staging"
    if ! gsutil ls -b $STAGING_BUCKET &>/dev/null; then
        echo "Creating staging bucket $STAGING_BUCKET..."
        gsutil mb -l $REGION $STAGING_BUCKET
    fi

    # FIX: Explicitly tell Cloud Build to use this valid bucket
    BUILD_ID=$(gcloud builds submit . \
        --tag $IMAGE_URL \
        --gcs-source-staging-dir="$STAGING_BUCKET/source" \
        --gcs-log-dir="$STAGING_BUCKET/logs" \
        --async \
        --format="value(id)")

    echo "Build started with ID: $BUILD_ID. Tracking status..."

    # Attempt to stream logs but don't fail if streaming fails
    gcloud builds log $BUILD_ID --stream || echo "Note: Log streaming failed, but the build is still running."

    # Wait for actual completion
    echo "Waiting for build $BUILD_ID to finish..."
    while true; do
        STATUS=$(gcloud builds describe $BUILD_ID --format="value(status)")
        case $STATUS in
            "SUCCESS")
                echo "Build finished successfully!"
                break
                ;;
            "FAILURE"|"INTERNAL_ERROR"|"TIMEOUT"|"CANCELLED")
                echo "Build finished with status: $STATUS"
                exit 1
                ;;
            *)
                echo "Current status: $STATUS... waiting 10s"
                sleep 10
                ;;
        esac
    done
fi

# 9. Update deployment.yaml with the new image
echo "Updating kubernetes.yaml with image URL..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i.bak "s|REPLACE_WITH_IMAGE_URL|$IMAGE_URL|g" kubernetes.yaml
else
    sed -i "s|REPLACE_WITH_IMAGE_URL|$IMAGE_URL|g" kubernetes.yaml
fi

# 10. Apply Kubernetes manifests
echo "Applying Kubernetes manifests..."
kubectl apply -f kubernetes.yaml

echo "Deployment complete!"
echo "Then visit http://localhost:8000"
