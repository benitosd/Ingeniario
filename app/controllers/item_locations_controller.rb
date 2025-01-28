# app/controllers/item_locations_controller.rb
class ItemLocationsController < ApplicationController
  before_action :set_stock, only: [:assign_to_user, :return_from_user]

  def assign_to_user
    @item_location = @stock.build_item_location(
      status: :assigned,
      user_id: params[:user_id],
      assigned_at: Time.current,
      return_date: params[:return_date],
      notes: params[:notes]
    )

    if @item_location.save
      redirect_to @stock.item, notice: 'Item asignado correctamente.'
    else
      redirect_to @stock.item, alert: 'Error al asignar el item.'
    end
  end

  def return_from_user
    @item_location = @stock.item_location
    
    if @item_location.update(
      status: :in_storage,
      section_id: params[:section_id],
      return_date: Time.current,
      notes: "#{@item_location.notes}\nDevuelto: #{params[:return_notes]}"
    )
      redirect_to @stock.item, notice: 'Item devuelto correctamente.'
    else
      redirect_to @stock.item, alert: 'Error al devolver el item.'
    end
  end

  private

  def set_stock
    @stock = Stock.find(params[:stock_id])
  end
end