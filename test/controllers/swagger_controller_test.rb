require "test_helper"

class SwaggerControllerTest < ActionDispatch::IntegrationTest
  test "should get swagger documentation" do
    get "/swagger/v1/swagger.json"
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type
  end
end
