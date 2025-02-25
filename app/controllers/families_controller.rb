class FamiliesController < ApplicationController
  before_action :set_family, only: %i[ show edit update update_inline destroy ]

  # GET /families or /families.json
  def index
    @search = Family.all.search do
      fulltext params[:search] unless params[:search].blank?
      paginate :page => params[:page] || 1, :per_page => 10
      order_by params[:order], params[:sort] unless params[:order].blank?
    end
    @families= @search.results
  end

  # GET /families/1 or /families/1.json
  def show
  end

  # GET /families/new
  def new
    @family=Family.new
   
  end
  # GET /families/1/edit
  def edit
  end

  # POST /families or /families.json
  def create
    @family = Family.new(family_params)

    if @family.save
      redirect_to @family, notice: 'Family was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /families/1 or /families/1.json
  def update
    respond_to do |format|
      if @family.update(family_params)
        format.turbo_stream { render turbo_stream: turbo_stream.prepend('families', partial: 'families/family', locals: {family: @family}) }
        format.html { redirect_to family_url(@family), notice: "Family was successfully updated." }
       else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @family.errors, status: :unprocessable_entity }
      end
    end
  end
  def update_inline
    if @family.update(family_params)
      render json: { success: true, family: @family }
    else
      render json: { success: false, errors: @family.errors.full_messages }
    end
  end
  # DELETE /families/1 or /families/1.json
  def destroy
    @family.destroy!

    respond_to do |format|
      format.html { redirect_to families_url, notice: "Family was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_family
      @family = Family.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def family_params
      params.require(:family).permit(:name, :description)
    end
end
