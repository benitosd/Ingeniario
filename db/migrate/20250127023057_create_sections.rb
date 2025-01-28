class CreateSections < ActiveRecord::Migration[7.1]
  def change
    create_table :sections do |t|
      t.string :name
      t.text :description
      t.references :warehouse, null: false, foreign_key: true
      t.integer :capacity
      t.string :location_code

      t.timestamps
    end
  end
end
