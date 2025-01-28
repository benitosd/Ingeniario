json.extract! warehouse, :id, :name, :description, :location, :contact_info, :created_at, :updated_at
json.url warehouse_url(warehouse, format: :json)