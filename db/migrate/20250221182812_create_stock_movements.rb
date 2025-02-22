class CreateStockMovements < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_movements do |t|
      t.references :stock, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :trackable, polymorphic: true, null: false
      t.string :action, null: false
      t.string :status, null: false
      t.text :notes

      t.timestamps
    end
  end
end 