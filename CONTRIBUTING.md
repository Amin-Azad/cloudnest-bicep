# Contributing

This is a personal portfolio project, but corrections and focused improvements are welcome.

Before opening a pull request:

1. Keep infrastructure changes small and explain the Azure behaviour being changed.
2. Run `./scripts/check-repository-hygiene.sh`.
3. Run `npm ci --prefix src` and `node --check src/app.js`.
4. Format and build the Bicep files with the pinned version used by CI.
5. Do not commit credentials, personal identifiers, generated Azure resource IDs or unsanitized screenshots.

Azure deployment must remain manual. A pull request must never create or remove Azure resources.
