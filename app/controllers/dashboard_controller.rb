# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
    def index
      @total_items = Item.count
      @total_stocks = Stock.count
      @active_stocks = Stock.active.count
      
      @stocks_in_storage = ItemLocation.in_storage.count
      @stocks_assigned = ItemLocation.assigned.count
      @stocks_in_repair = ItemLocation.in_repair.count
      @stocks_retired = ItemLocation.retired.count
      
      @top_warehouses = Warehouse.joins(sections: :item_locations)
                                .where(item_locations: { status: :in_storage })
                                .group('warehouses.id')
                                .select('warehouses.*, COUNT(item_locations.id) as items_count')
                                .order('items_count DESC')
                                .limit(5)
  
      @items_by_family = Family.joins(groups: :items)
                              .group('families.id, families.name')
                              .select('families.*, COUNT(items.id) as items_count')
                              .order('items_count DESC')
  
      @recent_movements = ItemLocation.includes(stock: :item)
                                    .order(created_at: :desc)
                                    .limit(5)
    end
  end