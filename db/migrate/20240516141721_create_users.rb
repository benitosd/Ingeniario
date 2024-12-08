class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
     
      t.boolean :active
      t.integer :directive
      t.string :email

      t.timestamps
    end
  end
end
