class CreateConversions < ActiveRecord::Migration[8.1]
  def change
    create_table :conversions do |t|
      t.string :source_currency_code, null: false, limit: 3
      t.string :target_currency_code, null: false, limit: 3

      t.decimal :source_amount, null: false, precision: 12, scale: 2
      t.decimal :target_amount, null: false, precision: 12, scale: 2

      t.timestamps null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end

    add_foreign_key :conversions, :currencies, column: :source_currency_code, primary_key: :code
    add_foreign_key :conversions, :currencies, column: :target_currency_code, primary_key: :code
  end
end
