class ConversionBlueprint < Blueprinter::Base
  identifier :id

  fields :source_currency_code, :target_currency_code, :source_amount, :target_amount, :created_at, :updated_at
end
