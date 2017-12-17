CREATE TRIGGER "transactions_category_update_timestamp_fields"
  BEFORE INSERT OR UPDATE ON "transactions_category"
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp_fields();

CREATE TRIGGER "transactions_transaction_update_timestamp_fields"
  BEFORE INSERT OR UPDATE ON "transactions_transaction"
  FOR EACH ROW EXECUTE PROCEDURE update_timestamp_fields();

CREATE TRIGGER "transactions_transaction_update_account_amount"
  BEFORE INSERT OR UPDATE OR DELETE ON "transactions_transaction"
  FOR EACH ROW EXECUTE PROCEDURE update_account_amount();
