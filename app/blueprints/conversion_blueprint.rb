# Serializes Conversion records to JSON for API responses.
#
# Returns all conversion attributes including both source and target amounts.
#
# @example Serialized output
#   {
#     "id": 1,
#     "source_currency_code": "MXN",
#     "target_currency_code": "USD",
#     "source_amount": 100.00,
#     "target_amount": 5.00,
#     "created_at": "2025-11-11T12:00:00Z",
#     "updated_at": "2025-11-11T12:00:00Z"
#   }
class ConversionBlueprint < Blueprinter::Base
  identifier :id

  fields :source_currency_code, :target_currency_code, :source_amount, :target_amount, :created_at, :updated_at
end
