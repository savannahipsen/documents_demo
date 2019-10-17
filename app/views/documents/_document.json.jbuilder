json.extract! document, :id, :name, :mime_type, :size, :created_at, :updated_at
json.url document_url(document, format: :json)
