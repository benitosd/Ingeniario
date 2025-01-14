class AddPropertiesToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :properties, :jsonb
  end
end
