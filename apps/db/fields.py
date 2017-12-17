from django.db import models


TRANSACTION_TYPES = (
    ('I', 'Income'),
    ('E', 'Expenditure'),
)


class TransactionTypeField(models.Field):

    def __init__(self, *args, **kwargs):
        kwargs['choices'] = TRANSACTION_TYPES
        super().__init__(*args, **kwargs)

    def db_type(self, connection):
        return 'transaction_type'
