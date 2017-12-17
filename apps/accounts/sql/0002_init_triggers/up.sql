CREATE TRIGGER "accounts_currency_update_timestamp_fields"
  BEFORE INSERT OR UPDATE ON "accounts_currency"
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp_fields();

CREATE TRIGGER "accounts_account_update_timestamp_fields"
  BEFORE INSERT OR UPDATE ON "accounts_account"
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp_fields();
