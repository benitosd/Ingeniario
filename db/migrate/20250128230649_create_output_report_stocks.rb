class CreateOutputReportStocks < ActiveRecord::Migration[7.0]
  def change
    create_table :output_report_stocks do |t|
      t.references :output_report, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true
      t.datetime :return_date
      t.text :notes

      t.timestamps
    end
  end
end