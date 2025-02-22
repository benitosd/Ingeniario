# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
    def index
      @total_items = Item.count
      @total_stocks = Stock.count
      @active_stocks = Stock.active.count
      
      @stocks_in_storage = Stock.joins(:item_location).where(item_locations: { status: :in_storage }).count
      @stocks_assigned = Stock.joins(:item_location).where(item_locations: { status: :assigned }).count
      @stocks_in_repair = Stock.joins(:item_location).where(item_locations: { status: :en_reparacion }).count
      @stocks_broken = Stock.joins(:item_location).where(item_locations: { status: :roto }).count
      @stocks_missing = Stock.joins(:item_location).where(item_locations: { status: :desaparecido }).count
      
      @items_by_group = Group.joins("LEFT JOIN items ON items.group_id = groups.id")
                            .select('groups.*, COUNT(items.id) as items_count')
                            .group('groups.id')
                            .order('items_count DESC')
  
      @top_warehouses = Warehouse.joins("LEFT JOIN sections ON sections.warehouse_id = warehouses.id")
                                .joins("LEFT JOIN item_locations ON item_locations.section_id = sections.id")
                                .select('warehouses.*, COUNT(DISTINCT item_locations.id) as items_count')
                                .group('warehouses.id')
                                .order('items_count DESC')
                                .limit(5)
  
      @recent_movements = StockMovement.includes(:stock, :user, stock: :item)
                                    .order(created_at: :desc)
                                    .limit(10)
    end
  end