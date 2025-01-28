class CreateStocks < ActiveRecord::Migration[7.1]
  def change
    create_table :stocks do |t|
      t.references :item, null: false, foreign_key: true
      t.string :reference
      t.text :description
      t.boolean :active
      t.datetime :entry_date

      t.timestamps
    end
  end
end
