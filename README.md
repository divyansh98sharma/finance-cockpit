# Finance Cockpit

Local-first personal finance cockpit for INR cash flow, dues, uploads, review, and debt-pressure planning.

## Current Scope

This branch contains the Next.js foundation and a static cockpit shell. It intentionally does not include persistence, ingestion, parsing, or account logic yet.

## Stack

- Next.js App Router
- TypeScript
- Tailwind CSS
- pnpm

Planned follow-up slices:

- `feat/prisma-domain-model` for PostgreSQL and Prisma tables
- `feat/local-document-vault` for uploads and local artifact storage
- `feat/finance-engine` for safe-to-spend and due-soon calculations
- `feat/review-inbox` for low-confidence import correction
- `feat/ai-parser` for Gemini-assisted structured extraction

## Development

```bash
pnpm install
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000).

## Branching

Work should land in small branches using conventional prefixes:

- `chore/*` for setup and tooling
- `feat/*` for product slices
- `fix/*` for defects
- `docs/*` for documentation-only changes
