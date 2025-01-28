class ChangeItemToStockInItemLocations < ActiveRecord::Migration[7.1]
  def change
    remove_reference :item_locations, :item
    add_reference :item_locations, :stock, null: false, foreign_key: true
  end
end
