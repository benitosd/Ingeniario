class CreateInputReportStocks < ActiveRecord::Migration[7.1]
  def change
    create_table :input_report_stocks do |t|
      t.references :input_report, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true
      t.references :section, null: false, foreign_key: true
      t.text :notes

      t.timestamps
    end
  end
end
