require "application_system_test_case"

class ItemLocationsTest < ApplicationSystemTestCase
  setup do
    @item_location = item_locations(:one)
  end

  test "visiting the index" do
    visit item_locations_url
    assert_selector "h1", text: "Item locations"
  end

  test "should create item location" do
    visit item_locations_url
    click_on "New item location"

    fill_in "Assigned at", with: @item_location.assigned_at
    fill_in "Item", with: @item_location.item_id
    fill_in "Notes", with: @item_location.notes
    fill_in "Return date", with: @item_location.return_date
    fill_in "Section", with: @item_location.section_id
    fill_in "Status", with: @item_location.status
    fill_in "User", with: @item_location.user_id
    click_on "Create Item location"

    assert_text "Item location was successfully created"
    click_on "Back"
  end

  test "should update Item location" do
    visit item_location_url(@item_location)
    click_on "Edit this item location", match: :first

    fill_in "Assigned at", with: @item_location.assigned_at
    fill_in "Item", with: @item_location.item_id
    fill_in "Notes", with: @item_location.notes
    fill_in "Return date", with: @item_location.return_date
    fill_in "Section", with: @item_location.section_id
    fill_in "Status", with: @item_location.status
    fill_in "User", with: @item_location.user_id
    click_on "Update Item location"

    assert_text "Item location was successfully updated"
    click_on "Back"
  end

  test "should destroy Item location" do
    visit item_location_url(@item_location)
    click_on "Destroy this item location", match: :first

    assert_text "Item location was successfully destroyed"
  end
end
