require "test_helper"

class Api::V1::TablesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @simple_table_html = load_table_fixture("table-1208.4.1.html")
    @complex_table_html = load_table_fixture("table-504.3.html")
  end

  def test_processes_table_successfully
    post "/api/v1/tables/process", params: { html: @simple_table_html }, as: :json

    assert_response :success
    assert_equal "success", JSON.parse(response.body)["status"]
    assert_not_empty JSON.parse(response.body)["data"]
  end

  def test_processes_complex_table
    post "/api/v1/tables/process", params: { html: @complex_table_html }, as: :json

    assert_response :success
    assert_equal "success", JSON.parse(response.body)["status"]
    assert_not_empty JSON.parse(response.body)["data"]
  end

  def test_handles_empty_html
    post "/api/v1/tables/process", params: { html: "" }, as: :json

    assert_response :success
    assert_equal "success", JSON.parse(response.body)["status"]
    assert_empty JSON.parse(response.body)["data"]
  end

  def test_handles_malformed_html
    post "/api/v1/tables/process", params: { html: "<div>Not a table</div>" }, as: :json

    assert_response :success
    assert_equal "success", JSON.parse(response.body)["status"]
    assert_empty JSON.parse(response.body)["data"]
  end

  def test_handles_missing_html_parameter
    post "/api/v1/tables/process", as: :json

    assert_response :unprocessable_entity
    assert_equal "error", JSON.parse(response.body)["status"]
    assert_not_empty JSON.parse(response.body)["message"]
  end
end
