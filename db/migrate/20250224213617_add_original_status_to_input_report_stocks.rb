class AddOriginalStatusToInputReportStocks < ActiveRecord::Migration[7.1]
  def change
    add_column :input_report_stocks, :original_status, :string
  end
end
