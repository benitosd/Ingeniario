class AddPropertiesToGroups < ActiveRecord::Migration[7.1]
  def change
    add_column :groups, :properties, :jsonb
  end
end
