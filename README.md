# Office Hub Converter

Minimal Render deployment for the Office Hub document converter. It runs
Gotenberg 8 behind Nginx and exposes:

- `GET /health`
- `POST /forms/libreoffice/convert`
- `POST /excel-to-pdf`

The application source remains in the private `office-hub` repository.
