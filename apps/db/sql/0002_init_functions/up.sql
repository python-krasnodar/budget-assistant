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
