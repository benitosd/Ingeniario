class ChangeUserIdToNullableInItemLocations < ActiveRecord::Migration[7.0]
  def change
    change_column_null :item_locations, :user_id, true
  end
end