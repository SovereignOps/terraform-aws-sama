# Azure Test Infrastructure

This test setup uses Azurite to mock Azure Storage for local testing.

## Usage

1. Start Azurite:
```bash
docker-compose up -d
```

2. Configure your Terraform backend or local usage to point to:
   - Blob endpoint: `http://127.0.0.1:10000/devstoreaccount1`
   - Queue endpoint: `http://127.0.0.1:10001/devstoreaccount1`
   - Table endpoint: `http://127.0.0.1:10002/devstoreaccount1`

## Credentials

The default Azurite credentials are:
- Account Name: `devstoreaccount1`
- Account Key: `Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==`
