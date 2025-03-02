class WarehousesController < ApplicationController
  before_action :set_warehouse, only: [:show, :edit, :update, :destroy]

  def index
    @search = Warehouse.all.search do
      fulltext params[:search] unless params[:search].blank?
      paginate page: params[:page] || 1, per_page: 10
      order_by params[:order], params[:sort] unless params[:order].blank?
    end
    @warehouses = @search.results
  end

  def show
    @sections = @warehouse.sections.includes(:item_locations)
  end

  def new
    @warehouse = Warehouse.new
  end

  def create
    @warehouse = Warehouse.new(warehouse_params)
    if @warehouse.save
      redirect_to @warehouse, notice: 'Almacén creado exitosamente.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @warehouse.update(warehouse_params)
      redirect_to @warehouse, notice: 'Almacén actualizado exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    @warehouse.destroy
    redirect_to warehouses_url, notice: 'Almacén eliminado exitosamente.'
  end
  def sections
    @warehouse = Warehouse.find(params[:id])
    render json: @warehouse.sections.select(:id, :name, :location_code)
  end

  private

  def set_warehouse
    @warehouse = Warehouse.find(params[:id])
  end

  def warehouse_params
    params.require(:warehouse).permit(:name, :description, :location, :contact_info, :image)
  end
end
