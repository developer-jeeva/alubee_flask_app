# Deploy Flask app to Google Cloud Run

This folder is set up to deploy **without** a service account JSON file in the repo. Cloud Run uses **Application Default Credentials** (the service account attached to the Cloud Run service).

## Prerequisites

- Google Cloud project with Cloud Run and BigQuery APIs enabled
- `gcloud` CLI installed and logged in (`gcloud auth login`)
- Docker (optional; you can use Cloud Build to build the image)

## 1. Set up the Cloud Run service account

1. In Google Cloud Console, go to **IAM & Admin** → **Service Accounts**.
2. Find the **default compute service account** used by Cloud Run (e.g. `PROJECT_NUMBER-compute@developer.gserviceaccount.com`) or create a dedicated service account for this app.
3. Grant that service account **BigQuery** permissions (e.g. **BigQuery Data Editor** and **BigQuery Job User**) so it can read/write your BigQuery datasets.

## 2. Deploy from the `production` folder

From the **production** directory (this folder):

```bash
# Set your project and region
export PROJECT_ID=your-gcp-project-id
export REGION=us-central1

# Build and deploy (Cloud Build will build the Docker image; no key file is uploaded)
gcloud run deploy alubee-app \
  --source . \
  --platform managed \
  --region $REGION \
  --project $PROJECT_ID \
  --allow-unauthenticated
```

Or build with Docker and push to Artifact Registry, then deploy:

```bash
# Build
docker build -t gcr.io/$PROJECT_ID/alubee-app:latest .

# Push (configure docker for gcr first: gcloud auth configure-docker)
docker push gcr.io/$PROJECT_ID/alubee-app:latest

# Deploy
gcloud run deploy alubee-app \
  --image gcr.io/$PROJECT_ID/alubee-app:latest \
  --platform managed \
  --region $REGION \
  --project $PROJECT_ID
```

## 3. Environment variables (optional)

- **GOOGLE_CLOUD_PROJECT** – Set automatically by Cloud Run. If you need to override, set it in Cloud Run → Edit & deploy new revision → Variables.
- **SECRET_KEY** – Set in Cloud Run **Variables** or **Secrets** for Flask session security (override the default in code).
- **BQ_CREDENTIALS_PATH** – Do **not** set in production. Only for local dev when using a key file outside the repo.

## 4. Local development with a key file

To use a key file locally without putting it in the repo:

```bash
export BQ_CREDENTIALS_PATH=/path/to/your/service-account-key.json
python main.py
```

The app never requires `bq_service_acc.json` in the repo; on Cloud Run it uses the attached service account automatically.
