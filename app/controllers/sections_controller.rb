class SectionsController < ApplicationController
  before_action :set_warehouse
  before_action :set_section, only: [:show, :edit, :update, :destroy] # update está listado pero no existe el método

  def index
    @search = @warehouse.sections.search do
      fulltext params[:search] unless params[:search].blank?
      paginate page: params[:page] || 1, per_page: 10
      order_by params[:order], params[:sort] unless params[:order].blank?
    end
    
    respond_to do |format|
      format.html { @sections = @search.results }
      format.json { render json: @warehouse.sections.select(:id, :name, :location_code) }
    end
  end

  def show
    @items = @section.item_locations.includes(:item)
  end

  def new
    @section = @warehouse.sections.build
  end

  def edit
  end

  def create
    @section = @warehouse.sections.build(section_params)
    if @section.save
      redirect_to warehouse_section_path(@warehouse, @section), notice: 'Sección creada exitosamente.'
    else
      render :new
    end
  end

  # Agregamos el método update que falta
  def update
    if @section.update(section_params)
      redirect_to warehouse_section_path(@warehouse, @section), notice: 'Sección actualizada exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    @section.destroy
    redirect_to warehouse_sections_path(@warehouse), notice: 'Sección eliminada exitosamente.'
  end

  private

  def set_warehouse
    # Primero intentamos obtener warehouse_id de los parámetros
    if params[:warehouse_id].present?
      @warehouse = Warehouse.find(params[:warehouse_id])
    # Si no hay warehouse_id pero hay section_id, obtenemos el warehouse a través de la sección
    elsif params[:id].present?
      begin
        section = Section.find(params[:id])
        @warehouse = section.warehouse
      rescue ActiveRecord::RecordNotFound
        flash[:alert] = 'No se encontró la sección especificada.'
        redirect_to warehouses_path and return
      end
    # Si no hay ni warehouse_id ni section_id válido, redirigimos
    else
      flash[:alert] = 'Se requiere especificar un almacén.'
      redirect_to warehouses_path and return
    end
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'No se encontró el almacén especificado.'
    redirect_to warehouses_path and return
  end

  def set_section
    @section = @warehouse.sections.find(params[:id])
  end

  def section_params
    params.require(:section).permit(:name, :description, :capacity, :location_code)
  end
end