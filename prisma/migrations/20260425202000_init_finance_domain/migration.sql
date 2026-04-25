-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "Institution" AS ENUM ('KOTAK', 'ICICI', 'CRED', 'OTHER');

-- CreateEnum
CREATE TYPE "SourceProvider" AS ENUM ('GMAIL', 'UPLOAD', 'MANUAL', 'SYSTEM');

-- CreateEnum
CREATE TYPE "SourceConnectionStatus" AS ENUM ('ACTIVE', 'PAUSED', 'ERROR', 'DISCONNECTED');

-- CreateEnum
CREATE TYPE "ArtifactKind" AS ENUM ('PDF', 'CSV', 'EXCEL', 'IMAGE', 'SCREENSHOT', 'EMAIL', 'TEXT', 'OTHER');

-- CreateEnum
CREATE TYPE "ProcessingStatus" AS ENUM ('PENDING', 'RUNNING', 'COMPLETED', 'NEEDS_REVIEW', 'FAILED');

-- CreateEnum
CREATE TYPE "IngestJobType" AS ENUM ('BACKFILL', 'INCREMENTAL', 'MANUAL_UPLOAD', 'REPROCESS');

-- CreateEnum
CREATE TYPE "ReviewRecordType" AS ENUM ('TRANSACTION', 'TRANSFER', 'OBLIGATION', 'INCOME', 'INVESTMENT', 'ACCOUNT', 'CARD');

-- CreateEnum
CREATE TYPE "ReviewStatus" AS ENUM ('OPEN', 'ACCEPTED', 'EDITED', 'REJECTED');

-- CreateEnum
CREATE TYPE "AccountType" AS ENUM ('SAVINGS', 'CURRENT', 'WALLET', 'CASH', 'OTHER');

-- CreateEnum
CREATE TYPE "CardNetwork" AS ENUM ('VISA', 'MASTERCARD', 'RUPAY', 'AMEX', 'OTHER');

-- CreateEnum
CREATE TYPE "TransactionDirection" AS ENUM ('DEBIT', 'CREDIT');

-- CreateEnum
CREATE TYPE "TransactionSourceType" AS ENUM ('BANK_STATEMENT', 'CARD_STATEMENT', 'EMAIL_ALERT', 'CRED_RECORD', 'MANUAL', 'OTHER');

-- CreateEnum
CREATE TYPE "LedgerRecordStatus" AS ENUM ('CONFIRMED', 'NEEDS_REVIEW', 'IGNORED');

-- CreateEnum
CREATE TYPE "ObligationType" AS ENUM ('CREDIT_CARD_DUE', 'BILL', 'EMI', 'RENT', 'SUBSCRIPTION', 'OTHER');

-- CreateEnum
CREATE TYPE "ObligationStatus" AS ENUM ('UPCOMING', 'PAID', 'OVERDUE', 'WAIVED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "InvestmentAssetType" AS ENUM ('MUTUAL_FUND', 'EQUITY', 'ETF', 'FIXED_DEPOSIT', 'PPF', 'NPS', 'OTHER');

-- CreateTable
CREATE TABLE "SourceConnection" (
    "id" TEXT NOT NULL,
    "provider" "SourceProvider" NOT NULL,
    "name" TEXT NOT NULL,
    "status" "SourceConnectionStatus" NOT NULL DEFAULT 'ACTIVE',
    "institution" "Institution",
    "accountEmail" TEXT,
    "externalId" TEXT,
    "metadata" JSONB,
    "lastSyncedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SourceConnection_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SourceArtifact" (
    "id" TEXT NOT NULL,
    "sourceConnectionId" TEXT,
    "kind" "ArtifactKind" NOT NULL,
    "originalName" TEXT NOT NULL,
    "mimeType" TEXT,
    "sizeBytes" BIGINT,
    "sha256" TEXT NOT NULL,
    "storagePath" TEXT NOT NULL,
    "statementPeriodStart" TIMESTAMP(3),
    "statementPeriodEnd" TIMESTAMP(3),
    "receivedAt" TIMESTAMP(3),
    "textExtractStatus" "ProcessingStatus" NOT NULL DEFAULT 'PENDING',
    "parseStatus" "ProcessingStatus" NOT NULL DEFAULT 'PENDING',
    "parserVersion" TEXT,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SourceArtifact_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "IngestJob" (
    "id" TEXT NOT NULL,
    "type" "IngestJobType" NOT NULL,
    "status" "ProcessingStatus" NOT NULL DEFAULT 'PENDING',
    "sourceConnectionId" TEXT,
    "sourceArtifactId" TEXT,
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "errorMessage" TEXT,
    "stats" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "IngestJob_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ReviewItem" (
    "id" TEXT NOT NULL,
    "recordType" "ReviewRecordType" NOT NULL,
    "status" "ReviewStatus" NOT NULL DEFAULT 'OPEN',
    "confidence" DECIMAL(5,4),
    "summary" TEXT NOT NULL,
    "proposedData" JSONB NOT NULL,
    "resolvedData" JSONB,
    "resolutionNote" TEXT,
    "sourceArtifactId" TEXT,
    "ingestJobId" TEXT,
    "resolvedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ReviewItem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Account" (
    "id" TEXT NOT NULL,
    "sourceConnectionId" TEXT,
    "institution" "Institution" NOT NULL,
    "name" TEXT NOT NULL,
    "type" "AccountType" NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'INR',
    "accountLast4" TEXT,
    "currentBalance" DECIMAL(18,2),
    "balanceAsOf" TIMESTAMP(3),
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Account_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Card" (
    "id" TEXT NOT NULL,
    "sourceConnectionId" TEXT,
    "linkedAccountId" TEXT,
    "institution" "Institution" NOT NULL,
    "name" TEXT NOT NULL,
    "network" "CardNetwork",
    "last4" TEXT,
    "currency" TEXT NOT NULL DEFAULT 'INR',
    "creditLimit" DECIMAL(18,2),
    "currentBalance" DECIMAL(18,2),
    "statementDate" INTEGER,
    "dueDay" INTEGER,
    "annualRate" DECIMAL(7,4),
    "minimumDue" DECIMAL(18,2),
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Card_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Transaction" (
    "id" TEXT NOT NULL,
    "accountId" TEXT,
    "cardId" TEXT,
    "sourceArtifactId" TEXT,
    "reviewItemId" TEXT,
    "occurredAt" TIMESTAMP(3) NOT NULL,
    "postedAt" TIMESTAMP(3),
    "description" TEXT NOT NULL,
    "merchant" TEXT,
    "amount" DECIMAL(18,2) NOT NULL,
    "direction" "TransactionDirection" NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'INR',
    "category" TEXT,
    "sourceType" "TransactionSourceType" NOT NULL,
    "externalId" TEXT,
    "dedupeKey" TEXT,
    "confidence" DECIMAL(5,4),
    "status" "LedgerRecordStatus" NOT NULL DEFAULT 'NEEDS_REVIEW',
    "raw" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Transaction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Transfer" (
    "id" TEXT NOT NULL,
    "fromAccountId" TEXT,
    "toAccountId" TEXT,
    "fromCardId" TEXT,
    "sourceArtifactId" TEXT,
    "reviewItemId" TEXT,
    "occurredAt" TIMESTAMP(3) NOT NULL,
    "amount" DECIMAL(18,2) NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'INR',
    "description" TEXT,
    "dedupeKey" TEXT,
    "confidence" DECIMAL(5,4),
    "status" "LedgerRecordStatus" NOT NULL DEFAULT 'NEEDS_REVIEW',
    "raw" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Transfer_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Obligation" (
    "id" TEXT NOT NULL,
    "type" "ObligationType" NOT NULL,
    "status" "ObligationStatus" NOT NULL DEFAULT 'UPCOMING',
    "accountId" TEXT,
    "cardId" TEXT,
    "sourceArtifactId" TEXT,
    "reviewItemId" TEXT,
    "payee" TEXT NOT NULL,
    "amount" DECIMAL(18,2) NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'INR',
    "dueDate" TIMESTAMP(3) NOT NULL,
    "paidAt" TIMESTAMP(3),
    "confidence" DECIMAL(5,4),
    "evidence" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Obligation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "IncomeEvent" (
    "id" TEXT NOT NULL,
    "accountId" TEXT,
    "sourceArtifactId" TEXT,
    "reviewItemId" TEXT,
    "receivedAt" TIMESTAMP(3) NOT NULL,
    "payer" TEXT,
    "amount" DECIMAL(18,2) NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'INR',
    "category" TEXT NOT NULL DEFAULT 'salary',
    "confidence" DECIMAL(5,4),
    "status" "LedgerRecordStatus" NOT NULL DEFAULT 'NEEDS_REVIEW',
    "raw" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "IncomeEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "InvestmentHolding" (
    "id" TEXT NOT NULL,
    "sourceArtifactId" TEXT,
    "institution" "Institution",
    "name" TEXT NOT NULL,
    "assetType" "InvestmentAssetType" NOT NULL,
    "symbol" TEXT,
    "units" DECIMAL(24,8),
    "averageCost" DECIMAL(18,2),
    "currentValue" DECIMAL(18,2),
    "currency" TEXT NOT NULL DEFAULT 'INR',
    "asOf" TIMESTAMP(3) NOT NULL,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "InvestmentHolding_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "SourceConnection_provider_status_idx" ON "SourceConnection"("provider", "status");

-- CreateIndex
CREATE INDEX "SourceConnection_institution_idx" ON "SourceConnection"("institution");

-- CreateIndex
CREATE UNIQUE INDEX "SourceArtifact_sha256_key" ON "SourceArtifact"("sha256");

-- CreateIndex
CREATE INDEX "SourceArtifact_kind_parseStatus_idx" ON "SourceArtifact"("kind", "parseStatus");

-- CreateIndex
CREATE INDEX "SourceArtifact_sourceConnectionId_idx" ON "SourceArtifact"("sourceConnectionId");

-- CreateIndex
CREATE INDEX "SourceArtifact_statementPeriodStart_statementPeriodEnd_idx" ON "SourceArtifact"("statementPeriodStart", "statementPeriodEnd");

-- CreateIndex
CREATE INDEX "IngestJob_status_createdAt_idx" ON "IngestJob"("status", "createdAt");

-- CreateIndex
CREATE INDEX "IngestJob_sourceConnectionId_idx" ON "IngestJob"("sourceConnectionId");

-- CreateIndex
CREATE INDEX "IngestJob_sourceArtifactId_idx" ON "IngestJob"("sourceArtifactId");

-- CreateIndex
CREATE INDEX "ReviewItem_status_recordType_idx" ON "ReviewItem"("status", "recordType");

-- CreateIndex
CREATE INDEX "ReviewItem_sourceArtifactId_idx" ON "ReviewItem"("sourceArtifactId");

-- CreateIndex
CREATE INDEX "ReviewItem_ingestJobId_idx" ON "ReviewItem"("ingestJobId");

-- CreateIndex
CREATE INDEX "Account_institution_type_idx" ON "Account"("institution", "type");

-- CreateIndex
CREATE INDEX "Account_sourceConnectionId_idx" ON "Account"("sourceConnectionId");

-- CreateIndex
CREATE INDEX "Card_institution_idx" ON "Card"("institution");

-- CreateIndex
CREATE INDEX "Card_sourceConnectionId_idx" ON "Card"("sourceConnectionId");

-- CreateIndex
CREATE INDEX "Card_linkedAccountId_idx" ON "Card"("linkedAccountId");

-- CreateIndex
CREATE INDEX "Transaction_occurredAt_idx" ON "Transaction"("occurredAt");

-- CreateIndex
CREATE INDEX "Transaction_accountId_occurredAt_idx" ON "Transaction"("accountId", "occurredAt");

-- CreateIndex
CREATE INDEX "Transaction_cardId_occurredAt_idx" ON "Transaction"("cardId", "occurredAt");

-- CreateIndex
CREATE INDEX "Transaction_status_idx" ON "Transaction"("status");

-- CreateIndex
CREATE INDEX "Transaction_sourceArtifactId_idx" ON "Transaction"("sourceArtifactId");

-- CreateIndex
CREATE UNIQUE INDEX "Transaction_dedupeKey_key" ON "Transaction"("dedupeKey");

-- CreateIndex
CREATE INDEX "Transfer_occurredAt_idx" ON "Transfer"("occurredAt");

-- CreateIndex
CREATE INDEX "Transfer_fromAccountId_idx" ON "Transfer"("fromAccountId");

-- CreateIndex
CREATE INDEX "Transfer_toAccountId_idx" ON "Transfer"("toAccountId");

-- CreateIndex
CREATE INDEX "Transfer_fromCardId_idx" ON "Transfer"("fromCardId");

-- CreateIndex
CREATE INDEX "Transfer_status_idx" ON "Transfer"("status");

-- CreateIndex
CREATE UNIQUE INDEX "Transfer_dedupeKey_key" ON "Transfer"("dedupeKey");

-- CreateIndex
CREATE INDEX "Obligation_status_dueDate_idx" ON "Obligation"("status", "dueDate");

-- CreateIndex
CREATE INDEX "Obligation_accountId_idx" ON "Obligation"("accountId");

-- CreateIndex
CREATE INDEX "Obligation_cardId_idx" ON "Obligation"("cardId");

-- CreateIndex
CREATE INDEX "Obligation_sourceArtifactId_idx" ON "Obligation"("sourceArtifactId");

-- CreateIndex
CREATE INDEX "IncomeEvent_receivedAt_idx" ON "IncomeEvent"("receivedAt");

-- CreateIndex
CREATE INDEX "IncomeEvent_accountId_idx" ON "IncomeEvent"("accountId");

-- CreateIndex
CREATE INDEX "IncomeEvent_status_idx" ON "IncomeEvent"("status");

-- CreateIndex
CREATE INDEX "InvestmentHolding_assetType_idx" ON "InvestmentHolding"("assetType");

-- CreateIndex
CREATE INDEX "InvestmentHolding_institution_idx" ON "InvestmentHolding"("institution");

-- CreateIndex
CREATE INDEX "InvestmentHolding_asOf_idx" ON "InvestmentHolding"("asOf");

-- CreateIndex
CREATE INDEX "InvestmentHolding_sourceArtifactId_idx" ON "InvestmentHolding"("sourceArtifactId");

-- AddForeignKey
ALTER TABLE "SourceArtifact" ADD CONSTRAINT "SourceArtifact_sourceConnectionId_fkey" FOREIGN KEY ("sourceConnectionId") REFERENCES "SourceConnection"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "IngestJob" ADD CONSTRAINT "IngestJob_sourceConnectionId_fkey" FOREIGN KEY ("sourceConnectionId") REFERENCES "SourceConnection"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "IngestJob" ADD CONSTRAINT "IngestJob_sourceArtifactId_fkey" FOREIGN KEY ("sourceArtifactId") REFERENCES "SourceArtifact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ReviewItem" ADD CONSTRAINT "ReviewItem_sourceArtifactId_fkey" FOREIGN KEY ("sourceArtifactId") REFERENCES "SourceArtifact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ReviewItem" ADD CONSTRAINT "ReviewItem_ingestJobId_fkey" FOREIGN KEY ("ingestJobId") REFERENCES "IngestJob"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Account" ADD CONSTRAINT "Account_sourceConnectionId_fkey" FOREIGN KEY ("sourceConnectionId") REFERENCES "SourceConnection"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Card" ADD CONSTRAINT "Card_sourceConnectionId_fkey" FOREIGN KEY ("sourceConnectionId") REFERENCES "SourceConnection"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Card" ADD CONSTRAINT "Card_linkedAccountId_fkey" FOREIGN KEY ("linkedAccountId") REFERENCES "Account"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "Account"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_cardId_fkey" FOREIGN KEY ("cardId") REFERENCES "Card"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_sourceArtifactId_fkey" FOREIGN KEY ("sourceArtifactId") REFERENCES "SourceArtifact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_reviewItemId_fkey" FOREIGN KEY ("reviewItemId") REFERENCES "ReviewItem"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transfer" ADD CONSTRAINT "Transfer_fromAccountId_fkey" FOREIGN KEY ("fromAccountId") REFERENCES "Account"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transfer" ADD CONSTRAINT "Transfer_toAccountId_fkey" FOREIGN KEY ("toAccountId") REFERENCES "Account"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transfer" ADD CONSTRAINT "Transfer_fromCardId_fkey" FOREIGN KEY ("fromCardId") REFERENCES "Card"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transfer" ADD CONSTRAINT "Transfer_sourceArtifactId_fkey" FOREIGN KEY ("sourceArtifactId") REFERENCES "SourceArtifact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transfer" ADD CONSTRAINT "Transfer_reviewItemId_fkey" FOREIGN KEY ("reviewItemId") REFERENCES "ReviewItem"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Obligation" ADD CONSTRAINT "Obligation_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "Account"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Obligation" ADD CONSTRAINT "Obligation_cardId_fkey" FOREIGN KEY ("cardId") REFERENCES "Card"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Obligation" ADD CONSTRAINT "Obligation_sourceArtifactId_fkey" FOREIGN KEY ("sourceArtifactId") REFERENCES "SourceArtifact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Obligation" ADD CONSTRAINT "Obligation_reviewItemId_fkey" FOREIGN KEY ("reviewItemId") REFERENCES "ReviewItem"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "IncomeEvent" ADD CONSTRAINT "IncomeEvent_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "Account"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "IncomeEvent" ADD CONSTRAINT "IncomeEvent_sourceArtifactId_fkey" FOREIGN KEY ("sourceArtifactId") REFERENCES "SourceArtifact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "IncomeEvent" ADD CONSTRAINT "IncomeEvent_reviewItemId_fkey" FOREIGN KEY ("reviewItemId") REFERENCES "ReviewItem"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InvestmentHolding" ADD CONSTRAINT "InvestmentHolding_sourceArtifactId_fkey" FOREIGN KEY ("sourceArtifactId") REFERENCES "SourceArtifact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

