class CreateItemLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :item_locations do |t|
      t.references :item, null: false, foreign_key: true
      t.references :section, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :status
      t.datetime :assigned_at
      t.datetime :return_date
      t.text :notes

      t.timestamps
    end
  end
end
