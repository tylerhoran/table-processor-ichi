Rswag::Api.configure do |c|
  # Specify a root folder where OpenAPI JSON files are located
  # This is used by the OpenAPI middleware to serve requests for API descriptions
  c.openapi_root = Rails.root.join("swagger").to_s
end
