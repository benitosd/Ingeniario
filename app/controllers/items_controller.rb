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
  end

  # GET /items/new
  def new
    @group.properties ||= {}

    @item = @group.items.build
    @item.properties ||= {}
  end

  # GET /items/1/edit
  def edit
    @group.properties ||= {}

    @item = @group.items.find(params[:id])
  end

  # POST /items or /items.json
  def create
    @item = @group.items.build(item_params)

    if @item.save
      redirect_to group_path(@group), notice: "Item created successfully."
    else
      flash.now[:alert] = "Failed to create item. Please check the errors below."
      render :new
    end
  end

  # PATCH/PUT /items/1 or /items/1.json
  def update
    @item = @group.items.find(params[:id])
    if @item.update(item_params)
      redirect_to group_path(@group), notice: "Item updated successfully."
    else
      render :edit
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params[:id])
    end
    def set_group
      if params[:group_id]
      @group = Group.find(params[:group_id])
      else
      @group=  Item.find(params[:id]).group
      end
    end
    # Only allow a list of trusted parameters through.
    def item_params
      params.require(:item).permit(:name, :description, :group_id, :photo, properties: {},properties_to_remove: [])
    end
end
