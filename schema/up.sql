CREATE TABLE IF NOT EXISTS "user" (
  "id" SERIAL PRIMARY KEY,
  "username" VARCHAR(255) NOT NULL UNIQUE,
  "email" VARCHAR(255) NOT NULL UNIQUE,
  "first_name" VARCHAR(255) DEFAULT NULL,
  "last_name" VARCHAR(255) DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS "currency" (
  "id" SERIAL PRIMARY KEY,
  "title" VARCHAR(255) NOT NULL,
  "iso4217" VARCHAR(3) NOT NULL UNIQUE,
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
  "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS "account" (
  "id" SERIAL PRIMARY KEY,
  "title" VARCHAR(255) NOT NULL,
  "description" TEXT DEFAULT NULL,
  "amount" DECIMAL(15, 2) NOT NULL DEFAULT 0,
  "user_id" INTEGER NOT NULL CONSTRAINT "fk_account_user_id" REFERENCES "user"("id"),
  "currency_id" INTEGER NOT NULL CONSTRAINT "fk_account_currency_id" REFERENCES "currency"("id"),
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
  "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS "expenditure_category" (
  "id" SERIAL PRIMARY KEY,
  "title" VARCHAR(255) NOT NULL,
  "description" TEXT DEFAULT NULL,
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
  "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS "income_category" (
  "id" SERIAL PRIMARY KEY,
  "title" VARCHAR(255) NOT NULL,
  "description" TEXT DEFAULT NULL,
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
  "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS "expenditure" (
  "id" SERIAL PRIMARY KEY,
  "amount" DECIMAL(15, 2) NOT NULL,
  "category_id" INTEGER NOT NULL CONSTRAINT "fk_expenditure_category_id" REFERENCES "expenditure_category"("id"),
  "account_id" INTEGER NOT NULL CONSTRAINT "fk_expenditure_account_id" REFERENCES "account"("id"),
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
  "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS "income" (
  "id" SERIAL PRIMARY KEY,
  "amount" DECIMAL(15, 2) NOT NULL,
  "category_id" INTEGER NOT NULL CONSTRAINT "fk_income_category_id" REFERENCES "income_category"("id"),
  "account_id" INTEGER NOT NULL CONSTRAINT "fk_income_account_id" REFERENCES "account"("id"),
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
  "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

CREATE OR REPLACE FUNCTION "update_timestamp_fields"() RETURNS trigger AS $update_timestamp_fields$
  BEGIN
    IF (TG_OP = 'INSERT') THEN
      NEW.created_at = now();
      RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
      NEW.created_at = OLD.created_at;
      NEW.updated_at = now();
      RETURN NEW;
    END IF;
  END;
$update_timestamp_fields$ LANGUAGE plpgsql;

CREATE TRIGGER "currency_update_timestamp_fields"
  BEFORE INSERT OR UPDATE ON "currency"
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp_fields();

CREATE TRIGGER "account_update_timestamp_fields"
  BEFORE INSERT OR UPDATE ON "account"
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp_fields();

CREATE TRIGGER "expenditure_category_update_timestamp_fields"
  BEFORE INSERT OR UPDATE ON "expenditure_category"
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp_fields();

CREATE TRIGGER "income_category_update_timestamp_fields"
  BEFORE INSERT OR UPDATE ON "income_category"
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp_fields();

CREATE TRIGGER "expenditure_update_timestamp_fields"
  BEFORE INSERT OR UPDATE ON "expenditure"
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp_fields();

CREATE TRIGGER "income_update_timestamp_fields"
  BEFORE INSERT OR UPDATE ON "income"
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp_fields();
