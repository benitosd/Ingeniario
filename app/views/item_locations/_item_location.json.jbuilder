json.extract! item_location, :id, :item_id, :section_id, :user_id, :status, :assigned_at, :return_date, :notes, :created_at, :updated_at
json.url item_location_url(item_location, format: :json)
