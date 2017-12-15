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

CREATE OR REPLACE FUNCTION "expenditure_update_account_amount"() RETURNS trigger AS $expenditure_update_account_amount$
  BEGIN
    IF (TG_OP = 'DELETE') THEN

      -- When expenditure delete row, we add old amount
      UPDATE "account"
        SET
          "amount" = "amount" + OLD.amount
        WHERE
          "id" = OLD.account_id;
      RETURN OLD;

    ELSIF (TG_OP = 'INSERT') THEN

      -- When expenditure insert row, we subtract new amount
      UPDATE "account"
        SET
          "amount" = "amount" - NEW.amount
        WHERE
          "id" = NEW.account_id;
      RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN

      -- When expenditure update row, we:
      --
      -- 1. add old amount
      -- 2. sub new amount
      UPDATE "account"
        SET
          "amount" = "amount" + OLD.amount
        WHERE
          "id" = OLD.account_id;

      UPDATE "account"
        SET
          "amount" = "amount" - NEW.amount
        WHERE
          "id" = NEW.account_id;
      RETURN NEW;

    END IF;
  END;
$expenditure_update_account_amount$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "income_update_account_amount"() RETURNS trigger AS $income_update_account_amount$
  BEGIN
    IF (TG_OP = 'DELETE') THEN

      -- When income delete row, we sub old amount
      UPDATE "account"
        SET
          "amount" = "amount" - OLD.amount
        WHERE
          "id" = OLD.account_id;
      RETURN OLD;

    ELSIF (TG_OP = 'INSERT') THEN

      -- When income insert row, we add new amount
      UPDATE "account"
        SET
          "amount" = "amount" + NEW.amount
        WHERE
          "id" = NEW.account_id;
      RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN

      -- When expenditure update row, we:
      --
      -- 1. sub old amount
      -- 2. add new amount
      UPDATE "account"
        SET
          "amount" = "amount" - OLD.amount
        WHERE
          "id" = OLD.account_id;

      UPDATE "account"
        SET
          "amount" = "amount" + NEW.amount
        WHERE
          "id" = NEW.account_id;
      RETURN NEW;

    END IF;
  END;
$income_update_account_amount$ LANGUAGE plpgsql;

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

CREATE TRIGGER "expenditure_amount_change"
  BEFORE INSERT OR UPDATE OR DELETE ON "expenditure"
  FOR EACH ROW EXECUTE PROCEDURE expenditure_update_account_amount();

CREATE TRIGGER "income_amount_change"
  BEFORE INSERT OR UPDATE OR DELETE ON "income"
  FOR EACH ROW EXECUTE PROCEDURE income_update_account_amount();


INSERT INTO "user"("username", "email") VALUES
  ('user0', 'user0@example.com'),
  ('user1', 'user1@example.com'),
  ('user2', 'user2@example.com'),
  ('user3', 'user3@example.com'),
  ('user4', 'user4@example.com');

INSERT INTO "currency"("title", "iso4217") VALUES
  ('Russian ruble', 'RUB'),
  ('Dollar', 'USD'),
  ('Euro', 'EUR'),
  ('Bitcoin', 'BTC');

INSERT INTO "account"("title", "user_id", "currency_id") VALUES
  ('Wallet', (SELECT id FROM "user" WHERE "username" = 'user0' LIMIT 1), (SELECT id FROM "currency" WHERE "iso4217" = 'RUB' LIMIT 1)),
  ('Crypto', (SELECT id FROM "user" WHERE "username" = 'user0' LIMIT 1), (SELECT id FROM "currency" WHERE "iso4217" = 'BTC' LIMIT 1)),
  ('Wallet', (SELECT id FROM "user" WHERE "username" = 'user1' LIMIT 1), (SELECT id FROM "currency" WHERE "iso4217" = 'USD' LIMIT 1)),
  ('Wallet', (SELECT id FROM "user" WHERE "username" = 'user3' LIMIT 1), (SELECT id FROM "currency" WHERE "iso4217" = 'EUR' LIMIT 1));

INSERT INTO "income_category"("title") VALUES
  ('Initial'),
  ('Salary'),
  ('Other');

INSERT INTO "expenditure_category"("title") VALUES
  ('Food'),
  ('Communal'),
  ('Education'),
  ('Health'),
  ('Entertainment');
