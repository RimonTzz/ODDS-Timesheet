json.extract! site, :id, :site_name, :location, :client_id, :created_at, :updated_at
json.url site_url(site, format: :json)
