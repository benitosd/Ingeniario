class ItemsController < ApplicationController
  
  before_action :set_group, only: %i[new show edit update]
  before_action :set_item, only: %i[show]
  # GET /items or /items.json
  def index
    @search = Item.all.search do
      fulltext params[:search] unless params[:search].blank?
      paginate :page => params[:page] || 1, :per_page => 10
      order_by params[:order], params[:sort] unless params[:order].blank?
    end
    @items= @search.results
  end

  # GET /items/1 or /items/1.json
  def show
    @item = Item.find(params[:id])
    @group = @item.group
    @properties = @item.properties || {}
    
    respond_to do |format|
      format.html
      format.json { render :show, status: :ok, location: @item }
    end
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Item not found"
    redirect_to items_path
  end

  # GET /items/new
  def new
    @group.properties ||= {}

    @item = @group.items.build
    @item.properties ||= {}
  end

  # GET /items/1/edit
  def edit
    @item = Item.find(params[:id])
    @group = @item.group
    @group.properties ||= {}
    @item.properties ||= {}
  end

  # POST /items or /items.json
  def create
    @group = Group.find(params[:group_id])
    @item = @group.items.build(item_params)
    
    # Inicializamos las propiedades
    @item.properties ||= {}
    
    # Procesamos las propiedades recibidas
    if params[:item][:properties].present?
      params[:item][:properties].each do |key, value|
        if value.present?
          @item.properties[key] = value
        end
      end
    end

    if @item.save
      redirect_to group_path(@group), notice: "Item created successfully."
    else
      flash.now[:alert] = "Failed to create item. Please check the errors below."
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /items/1 or /items/1.json
  def update
    @item = Item.find(params[:id])
    @group = @item.group
    
    # Inicializamos las propiedades
    @item.properties ||= {}
    
    if params[:item][:properties].present?
      # Actualizamos las propiedades existentes
      params[:item][:properties].each do |key, value|
        if value.present?
          @item.properties[key] = value
        else
          @item.properties.delete(key)
        end
      end
    end

    if @item.update(item_params)
      redirect_to item_path(@item), notice: "Item was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end


  # DELETE /items/1 or /items/1.json
  def destroy
    @item.destroy!

    respond_to do |format|
      format.html { redirect_to items_path, status: :see_other, notice: "Item was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  def assign_to_user
    @item = Item.find(params[:id])
    @item_location = @item.build_item_location(
      user: User.find(params[:user_id]),
      status: :assigned,
      assigned_at: Time.current,
      return_date: params[:return_date]
    )
    
    if @item_location.save
      redirect_to @item, notice: 'Item asignado correctamente.'
    else
      render :show
    end
  end
  
  def move_to_section
    @item = Item.find(params[:id])
    @item_location = @item.build_item_location(
      section: Section.find(params[:section_id]),
      status: :in_storage,
      assigned_at: Time.current
    )
    
    if @item_location.save
      redirect_to @item, notice: 'Item movido correctamente.'
    else
      render :show
    end
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "Item not found"
      redirect_to items_path
    end
    def set_group
      @group = Group.find(params[:group_id]) if params[:group_id]
    end
    # Only allow a list of trusted parameters through.
    def item_params
      params.require(:item).permit(:name, :description, :group_id, :photo, properties: {})
    end
end
