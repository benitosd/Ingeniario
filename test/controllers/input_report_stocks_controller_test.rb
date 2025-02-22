require "test_helper"

class InputReportStocksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @input_report_stock = input_report_stocks(:one)
  end

  test "should get index" do
    get input_report_stocks_url
    assert_response :success
  end

  test "should get new" do
    get new_input_report_stock_url
    assert_response :success
  end

  test "should create input_report_stock" do
    assert_difference("InputReportStock.count") do
      post input_report_stocks_url, params: { input_report_stock: { input_report_id: @input_report_stock.input_report_id, notes: @input_report_stock.notes, section_id: @input_report_stock.section_id, stock_id: @input_report_stock.stock_id } }
    end

    assert_redirected_to input_report_stock_url(InputReportStock.last)
  end

  test "should show input_report_stock" do
    get input_report_stock_url(@input_report_stock)
    assert_response :success
  end

  test "should get edit" do
    get edit_input_report_stock_url(@input_report_stock)
    assert_response :success
  end

  test "should update input_report_stock" do
    patch input_report_stock_url(@input_report_stock), params: { input_report_stock: { input_report_id: @input_report_stock.input_report_id, notes: @input_report_stock.notes, section_id: @input_report_stock.section_id, stock_id: @input_report_stock.stock_id } }
    assert_redirected_to input_report_stock_url(@input_report_stock)
  end

  test "should destroy input_report_stock" do
    assert_difference("InputReportStock.count", -1) do
      delete input_report_stock_url(@input_report_stock)
    end

    assert_redirected_to input_report_stocks_url
  end
end
