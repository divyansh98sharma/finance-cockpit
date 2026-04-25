# Finance Cockpit

Local-first personal finance cockpit for INR cash flow, dues, uploads, review, and debt-pressure planning.

## Current Scope

This branch contains the Next.js foundation and a static cockpit shell. It intentionally does not include persistence, ingestion, parsing, or account logic yet.

## Stack

- Next.js App Router
- TypeScript
- Tailwind CSS
- npm
- PostgreSQL
- Prisma ORM

Planned follow-up slices:

- `feat/local-document-vault` for uploads and local artifact storage
- `feat/finance-engine` for safe-to-spend and due-soon calculations
- `feat/review-inbox` for low-confidence import correction
- `feat/ai-parser` for Gemini-assisted structured extraction

## Development

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

## Database

Create a local environment file:

```bash
cp .env.example .env
```

Set `DATABASE_URL` to a local PostgreSQL database, then run:

```bash
npm run db:generate
npm run db:migrate
```

Useful database commands:

- `npm run db:validate` checks the Prisma schema
- `npm run db:generate` regenerates Prisma Client
- `npm run db:migrate` applies local migrations
- `npm run db:studio` opens Prisma Studio

## Branching

Work should land in small branches using conventional prefixes:

- `chore/*` for setup and tooling
- `feat/*` for product slices
- `fix/*` for defects
- `docs/*` for documentation-only changes
