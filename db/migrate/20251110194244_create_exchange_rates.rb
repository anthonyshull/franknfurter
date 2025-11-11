class CreateExchangeRates < ActiveRecord::Migration[8.1]
  def up
    create_table :exchange_rates do |t|
      t.string :left_currency_code, null: false, limit: 3
      t.string :right_currency_code, null: false, limit: 3

      # The greatest fidelity the API offers is date.
      t.date :date, null: false
  
      # The API has limited precision.
      # This is likely a wider margin than we need.
      t.decimal :rate, null: false, precision: 10, scale: 5
    end

    add_foreign_key :exchange_rates, :currencies, column: :left_currency_code, primary_key: :code
    add_foreign_key :exchange_rates, :currencies, column: :right_currency_code, primary_key: :code
    
    # This gives us an index for very fast lookups.
    add_index :exchange_rates, [:left_currency_code, :right_currency_code, :date], name: 'exchange_rates_index'
    
    # We want to make sure that the currencies are always ordered alphabetically.
    # This allows us to NOT duplicate requests for currencies that are just inversions of each other.
    # The request for USD -> MXN is always calculated as MXN -> USD.
    execute <<-SQL
      ALTER TABLE exchange_rates
      ADD CONSTRAINT left_less_than_right
      CHECK (left_currency_code < right_currency_code)
    SQL
  end

  def down
    drop_table :exchange_rates
  end
end
