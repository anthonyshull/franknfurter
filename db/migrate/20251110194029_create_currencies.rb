class CreateCurrencies < ActiveRecord::Migration[8.1]
  def change
    create_table :currencies, id: false do |t|
      t.string :code, null: false, primary_key: true, limit: 3
    end
  end
end
