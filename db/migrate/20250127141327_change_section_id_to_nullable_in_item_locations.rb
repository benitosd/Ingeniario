class ChangeSectionIdToNullableInItemLocations < ActiveRecord::Migration[7.0]
  def change
    change_column_null :item_locations, :section_id, true
  end
end