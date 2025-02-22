require "application_system_test_case"

class InputReportsTest < ApplicationSystemTestCase
  setup do
    @input_report = input_reports(:one)
  end

  test "visiting the index" do
    visit input_reports_url
    assert_selector "h1", text: "Input reports"
  end

  test "should create input report" do
    visit input_reports_url
    click_on "New input report"

    fill_in "Date", with: @input_report.date
    fill_in "Notes", with: @input_report.notes
    fill_in "Output report", with: @input_report.output_report_id
    fill_in "Status", with: @input_report.status
    fill_in "User", with: @input_report.user_id
    click_on "Create Input report"

    assert_text "Input report was successfully created"
    click_on "Back"
  end

  test "should update Input report" do
    visit input_report_url(@input_report)
    click_on "Edit this input report", match: :first

    fill_in "Date", with: @input_report.date
    fill_in "Notes", with: @input_report.notes
    fill_in "Output report", with: @input_report.output_report_id
    fill_in "Status", with: @input_report.status
    fill_in "User", with: @input_report.user_id
    click_on "Update Input report"

    assert_text "Input report was successfully updated"
    click_on "Back"
  end

  test "should destroy Input report" do
    visit input_report_url(@input_report)
    click_on "Destroy this input report", match: :first

    assert_text "Input report was successfully destroyed"
  end
end
