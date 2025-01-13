class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.string :name
      t.text :description
      t.json :properties
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
