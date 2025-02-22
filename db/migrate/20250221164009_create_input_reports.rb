class CreateInputReports < ActiveRecord::Migration[7.1]
  def change
    create_table :input_reports do |t|
      t.references :output_report, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.date :date
      t.text :notes
      t.integer :status

      t.timestamps
    end
  end
end
