require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
    assert_select "h1", "Table Processor API"
    assert_select "a[href=?]", "/api-docs", "Go to API Documentation"
  end
end
