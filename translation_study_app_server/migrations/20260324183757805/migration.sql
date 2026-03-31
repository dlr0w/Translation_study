BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "user_review_result" (
    "id" bigserial PRIMARY KEY,
    "userIdentifier" text NOT NULL,
    "clientRecordId" text NOT NULL,
    "historyClientRecordId" text NOT NULL,
    "answerText" text NOT NULL,
    "grade" text NOT NULL,
    "reviewedAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "user_review_result_user_client_record_idx" ON "user_review_result" USING btree ("userIdentifier", "clientRecordId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "user_translation_history" (
    "id" bigserial PRIMARY KEY,
    "userIdentifier" text NOT NULL,
    "clientRecordId" text NOT NULL,
    "sourceText" text NOT NULL,
    "translatedText" text NOT NULL,
    "sourceLanguage" text NOT NULL,
    "targetLanguage" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "isFavorite" boolean NOT NULL,
    "tagsJson" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "user_translation_history_user_client_record_idx" ON "user_translation_history" USING btree ("userIdentifier", "clientRecordId");


--
-- MIGRATION VERSION FOR translation_study_app
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('translation_study_app', '20260324183757805', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260324183757805', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260129181124635', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181124635', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260129181112269', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181112269', "timestamp" = now();


COMMIT;
