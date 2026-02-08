# GCP Test Infrastructure

This setup mocks Google Cloud Storage (GCS) using `fsouza/fake-gcs-server`.

## Usage

1. Start fake-gcs-server:
```bash
docker-compose up -d
```

2. Point your Terraform provider or Google Cloud SDK to `http://localhost:4443`.

## Notes
- This mocks GCS only.
- For other services, use `terraform validate` and `plan` against a mock project ID.
