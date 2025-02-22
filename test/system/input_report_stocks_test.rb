require "application_system_test_case"

class InputReportStocksTest < ApplicationSystemTestCase
  setup do
    @input_report_stock = input_report_stocks(:one)
  end

  test "visiting the index" do
    visit input_report_stocks_url
    assert_selector "h1", text: "Input report stocks"
  end

  test "should create input report stock" do
    visit input_report_stocks_url
    click_on "New input report stock"

    fill_in "Input report", with: @input_report_stock.input_report_id
    fill_in "Notes", with: @input_report_stock.notes
    fill_in "Section", with: @input_report_stock.section_id
    fill_in "Stock", with: @input_report_stock.stock_id
    click_on "Create Input report stock"

    assert_text "Input report stock was successfully created"
    click_on "Back"
  end

  test "should update Input report stock" do
    visit input_report_stock_url(@input_report_stock)
    click_on "Edit this input report stock", match: :first

    fill_in "Input report", with: @input_report_stock.input_report_id
    fill_in "Notes", with: @input_report_stock.notes
    fill_in "Section", with: @input_report_stock.section_id
    fill_in "Stock", with: @input_report_stock.stock_id
    click_on "Update Input report stock"

    assert_text "Input report stock was successfully updated"
    click_on "Back"
  end

  test "should destroy Input report stock" do
    visit input_report_stock_url(@input_report_stock)
    click_on "Destroy this input report stock", match: :first

    assert_text "Input report stock was successfully destroyed"
  end
end
