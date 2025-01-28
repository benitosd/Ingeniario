class CreateWarehouses < ActiveRecord::Migration[7.1]
  def change
    create_table :warehouses do |t|
      t.string :name
      t.text :description
      t.string :location
      t.string :contact_info

      t.timestamps
    end
  end
end
