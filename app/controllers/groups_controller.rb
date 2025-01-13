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
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups or /groups.json
  def create
    @group = Group.new(group_params)
    process_properties(@group, params[:group][:properties])
    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: "Group was successfully created." }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1 or /groups/1.json
  def create
    @group = Group.new(group_params)
    @group.properties ||= {}
    if @group.save
      redirect_to @group, notice: "Group created successfully."
    else
      render :new
    end
  end

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
      params.require(:group).permit(:name, :description, :family_id,properties: {})
    end
    def process_properties(properties_params)
      return unless properties_params
    
      updated_properties = @group.properties || {}
    
      properties_params.each do |key, property|
         Rails.logger.debug "########################################################"
       Rails.logger.debug "Properties enviados: #{params[:group][:properties].inspect}"
        if key == "new_key" # Nueva propiedad
          unique_key = SecureRandom.uuid # Generar clave única
          updated_properties[unique_key] = { "key" => unique_key, "value" => property["value"] }
        elsif property["value"].present? # Propiedad existente
          updated_properties[key] = { "key" => key, "value" => property["value"] }
        else
          updated_properties.delete(key) # Eliminar propiedad si el valor está vacío
        end
      end
    
      @group.properties = updated_properties
    end
    
    
end
