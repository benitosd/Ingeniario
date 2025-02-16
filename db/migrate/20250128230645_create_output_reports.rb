class CreateOutputReports < ActiveRecord::Migration[7.0]
  def change
    create_table :output_reports do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :date, null: false
      t.text :reason
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
