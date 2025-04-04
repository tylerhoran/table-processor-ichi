class SwaggerController < ApplicationController
  layout "swagger"

  def index
    render file: Rails.root.join("swagger", "v1", "swagger.json"), content_type: "application/json"
  end
end
