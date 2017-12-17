-- ---------------------------------------------------------------------------------------------------------------------
-- Data Types Section
-- ---------------------------------------------------------------------------------------------------------------------

CREATE TYPE "transaction_type" AS ENUM('I', 'E');

-- ---------------------------------------------------------------------------------------------------------------------
-- Tables Section
-- ---------------------------------------------------------------------------------------------------------------------

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

CREATE TABLE IF NOT EXISTS "transaction_category" (
  "id" SERIAL PRIMARY KEY,
  "type" transaction_type NOT NULL,
  "title" VARCHAR(255) NOT NULL,
  "description" TEXT DEFAULT NULL,
  "user_id" INTEGER NOT NULL CONSTRAINT "fk_transaction_category_user_id" REFERENCES "user"("id"),
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
  "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS "transaction" (
  "id" SERIAL PRIMARY KEY,
  "type" transaction_type NOT NULL,
  "amount" DECIMAL(15, 2) NOT NULL,
  "category_id" INTEGER NOT NULL CONSTRAINT "fk_transaction_category_id" REFERENCES "transaction_category"("id"),
  "account_id" INTEGER NOT NULL CONSTRAINT "fk_transaction_account_id" REFERENCES "account"("id"),
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
  "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

-- ---------------------------------------------------------------------------------------------------------------------
-- Functions Section
-- ---------------------------------------------------------------------------------------------------------------------

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

CREATE OR REPLACE FUNCTION "update_account_amount"() RETURNS trigger AS $update_account_amount$
  DECLARE
    account_user_id INTEGER;
    category_user_id INTEGER;
  BEGIN

    -- Check transaction category id
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN

      SELECT "user_id" INTO account_user_id FROM "account" WHERE "id" = NEW.account_id;
      SELECT "user_id" INTO category_user_id FROM "transaction_category" WHERE "id" = NEW.category_id;

      IF (account_user_id != category_user_id) THEN
        RAISE EXCEPTION 'Invalid transaction category id';
      END IF;

    END IF;

    IF (TG_OP = 'DELETE') THEN

      IF (OLD.type = 'E') THEN
        UPDATE "account" SET "amount" = "amount" + OLD.amount WHERE "id" = OLD.account_id;
      ELSIF (OLD.type = 'I') THEN
        UPDATE "account" SET "amount" = "amount" - OLD.amount WHERE "id" = OLD.account_id;
      END IF;

      RETURN OLD;

    ELSIF (TG_OP = 'INSERT') THEN

      IF (NEW.type = 'E') THEN
        UPDATE "account" SET "amount" = "amount" - NEW.amount WHERE "id" = NEW.account_id;
      ELSEIF (NEW.type = 'I') THEN
        UPDATE "account" SET "amount" = "amount" + NEW.amount WHERE "id" = NEW.account_id;
      END IF;

      RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN

      IF (OLD.type = 'E') THEN
        UPDATE "account" SET "amount" = "amount" + OLD.amount WHERE "id" = OLD.account_id;
      ELSIF (OLD.type = 'I') THEN
        UPDATE "account" SET "amount" = "amount" - OLD.amount WHERE "id" = OLD.account_id;
      END IF;

      IF (NEW.type = 'E') THEN
        UPDATE "account" SET "amount" = "amount" - NEW.amount WHERE "id" = NEW.account_id;
      ELSIF (NEW.type = 'I') THEN
        UPDATE "account" SET "amount" = "amount" + NEW.amount WHERE "id" = NEW.account_id;
      END IF;

      RETURN NEW;

    END IF;
  END;
$update_account_amount$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------------------------------------------------
-- Triggers Section
-- ---------------------------------------------------------------------------------------------------------------------

CREATE TRIGGER "currency_update_timestamp_fields"
  BEFORE INSERT OR UPDATE ON "currency"
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp_fields();

CREATE TRIGGER "account_update_timestamp_fields"
  BEFORE INSERT OR UPDATE ON "account"
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp_fields();

CREATE TRIGGER "transaction_category_update_timestamp_fields"
  BEFORE INSERT OR UPDATE ON "transaction_category"
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp_fields();

CREATE TRIGGER "transaction_update_timestamp_fields"
  BEFORE INSERT OR UPDATE ON "transaction"
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp_fields();

CREATE TRIGGER "transaction_update_account_amount"
  BEFORE INSERT OR UPDATE OR DELETE ON "transaction"
  FOR EACH ROW EXECUTE PROCEDURE update_account_amount();

-- ---------------------------------------------------------------------------------------------------------------------
-- Data Section
-- ---------------------------------------------------------------------------------------------------------------------

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
  (
    'Wallet',
    (SELECT id FROM "user" WHERE "username" = 'user0' LIMIT 1),
    (SELECT id FROM "currency" WHERE "iso4217" = 'RUB' LIMIT 1)
  ),
  (
    'Crypto',
    (SELECT id FROM "user" WHERE "username" = 'user0' LIMIT 1),
    (SELECT id FROM "currency" WHERE "iso4217" = 'BTC' LIMIT 1)
  ),
  (
    'Wallet',
    (SELECT id FROM "user" WHERE "username" = 'user1' LIMIT 1),
    (SELECT id FROM "currency" WHERE "iso4217" = 'USD' LIMIT 1)
  ),
  (
    'Wallet',
    (SELECT id FROM "user" WHERE "username" = 'user3' LIMIT 1),
    (SELECT id FROM "currency" WHERE "iso4217" = 'EUR' LIMIT 1)
  );

INSERT INTO "transaction_category"("type", "title", "user_id") VALUES
  (
    'I',
    'Initial',
    (SELECT "id" FROM "user" WHERE "username" = 'user0')
  ),
  (
    'I',
    'Salary',
    (SELECT "id" FROM "user" WHERE "username" = 'user0')
  ),
  (
    'I',
    'Other',
    (SELECT "id" FROM "user" WHERE "username" = 'user0')
  ),
  (
    'E',
    'Food',
    (SELECT "id" FROM "user" WHERE "username" = 'user0')
  ),
  (
    'E',
    'Communal',
    (SELECT "id" FROM "user" WHERE "username" = 'user0')
  ),
  (
    'E',
    'Education',
    (SELECT "id" FROM "user" WHERE "username" = 'user0')
  ),
  (
    'E',
    'Health',
    (SELECT "id" FROM "user" WHERE "username" = 'user0')
  ),
  (
    'E',
    'Entertainment',
    (SELECT "id" FROM "user" WHERE "username" = 'user0')
  );
