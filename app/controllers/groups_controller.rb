class GroupsController < ApplicationController
  before_action :set_group, only: %i[show edit update]

  # GET /groups or /groups.json
  def index
    @search = Group.all.search do
      fulltext params[:search] unless params[:search].blank?
      paginate :page => params[:page] || 1, :per_page => 10
      order_by params[:order], params[:sort] unless params[:order].blank?
    end
    @groups= @search.results
  end

  # GET /groups/1 or /groups/1.json
  def show
  end

  # GET /groups/new
  def new
    @group = Group.new
    @group.family_id = params[:family_id] if params[:family_id].present?
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups or /groups.json
  def create
    @group = Group.new(group_params)
    @group.family_id = params[:group][:family_id] || params[:family_id]
    
    respond_to do |format|
      @group.properties ||= {}
      
      if params[:group][:properties].present?
        params[:group][:properties].each do |key, value|
          if value.present?
            # Convertimos la clave a un formato más amigable (snake_case)
            property_key = key.to_s.parameterize(separator: '_')
            @group.properties[property_key] = value
          end
        end
      end

      if @group.save
        format.html { redirect_to @group, notice: "Group was successfully created." }
        format.json { render :show, status: :created, location: @group }
        format.turbo_stream { redirect_to @group, notice: "Group was successfully created." }
      else
        format.html { 
          flash.now[:alert] = @group.errors.full_messages.join(", ")
          render :new, status: :unprocessable_entity 
        }
        format.json { render json: @group.errors, status: :unprocessable_entity }
        format.turbo_stream { 
          flash.now[:alert] = @group.errors.full_messages.join(", ")
          render :new, status: :unprocessable_entity 
        }
      end
    end
  end

  # PATCH/PUT /groups/1 or /groups/1.json
  

  def edit; end

  def update
    params[:group][:properties] ||= {}
     # Genera claves autoincrementales
    if @group.update(group_params)
      redirect_to @group, notice: "Group updated successfully."
    else
      render :edit
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_params
      params.require(:group).permit(:name, :description, :family_id, properties: {})
    end
    def process_properties(properties_params)
      return unless properties_params
    
      @group.properties ||= {}
    
      properties_params.each do |key, value|
        if value.present?
          @group.properties[key] = { "key" => key, "value" => value }
        else
          @group.properties.delete(key)
        end
      end
    end
    
    
end
