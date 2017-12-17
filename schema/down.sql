-- ---------------------------------------------------------------------------------------------------------------------
-- Triggers Section
-- ---------------------------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS "transaction_update_account_amount" ON "transaction";
DROP TRIGGER IF EXISTS "transaction_update_timestamp_fields" ON "transaction";
DROP TRIGGER IF EXISTS "transaction_category_update_timestamp_fields" ON "transaction_category";
DROP TRIGGER IF EXISTS "account_update_timestamp_fields" ON "account";
DROP TRIGGER IF EXISTS "currency_update_timestamp_fields" ON "currency";

-- ---------------------------------------------------------------------------------------------------------------------
-- Functions Section
-- ---------------------------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS update_account_amount();
DROP FUNCTION IF EXISTS update_timestamp_fields();

-- ---------------------------------------------------------------------------------------------------------------------
-- Tables Section
-- ---------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS "transaction";
DROP TABLE IF EXISTS "transaction_category";
DROP TABLE IF EXISTS "account";
DROP TABLE IF EXISTS "currency";
DROP TABLE IF EXISTS "user";

-- ---------------------------------------------------------------------------------------------------------------------
-- Data Types Section
-- ---------------------------------------------------------------------------------------------------------------------

DROP TYPE IF EXISTS "transaction_type";
