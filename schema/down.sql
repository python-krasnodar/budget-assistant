DROP TRIGGER IF EXISTS "expenditure_update_timestamp_fields" ON "expenditure";
DROP TRIGGER IF EXISTS "income_update_timestamp_fields" ON "income";
DROP TRIGGER IF EXISTS "expenditure_category_update_timestamp_fields" ON "expenditure_category";
DROP TRIGGER IF EXISTS "income_category_update_timestamp_fields" ON "income_category";
DROP TRIGGER IF EXISTS "currency_update_timestamp_fields" ON "currency";
DROP TRIGGER IF EXISTS "account_update_timestamp_fields" ON "account";

DROP FUNCTION IF EXISTS update_timestamp_fields();

DROP TABLE IF EXISTS "income";
DROP TABLE IF EXISTS "expenditure";
DROP TABLE IF EXISTS "income_category";
DROP TABLE IF EXISTS "expenditure_category";

DROP TABLE IF EXISTS "account";
DROP TABLE IF EXISTS "currency";
DROP TABLE IF EXISTS "user";
