require "test_helper"

class InputReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @input_report = input_reports(:one)
  end

  test "should get index" do
    get input_reports_url
    assert_response :success
  end

  test "should get new" do
    get new_input_report_url
    assert_response :success
  end

  test "should create input_report" do
    assert_difference("InputReport.count") do
      post input_reports_url, params: { input_report: { date: @input_report.date, notes: @input_report.notes, output_report_id: @input_report.output_report_id, status: @input_report.status, user_id: @input_report.user_id } }
    end

    assert_redirected_to input_report_url(InputReport.last)
  end

  test "should show input_report" do
    get input_report_url(@input_report)
    assert_response :success
  end

  test "should get edit" do
    get edit_input_report_url(@input_report)
    assert_response :success
  end

  test "should update input_report" do
    patch input_report_url(@input_report), params: { input_report: { date: @input_report.date, notes: @input_report.notes, output_report_id: @input_report.output_report_id, status: @input_report.status, user_id: @input_report.user_id } }
    assert_redirected_to input_report_url(@input_report)
  end

  test "should destroy input_report" do
    assert_difference("InputReport.count", -1) do
      delete input_report_url(@input_report)
    end

    assert_redirected_to input_reports_url
  end
end
