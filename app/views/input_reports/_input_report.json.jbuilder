json.extract! input_report, :id, :output_report_id, :user_id, :date, :notes, :status, :created_at, :updated_at
json.url input_report_url(input_report, format: :json)
