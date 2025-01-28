class StocksController < ApplicationController
  before_action :set_stock, only: %i[ show edit update destroy assign_to_user return_from_user move_to_section]

  # GET /stocks or /stocks.json
  def index
    @search = Stock.search do
      fulltext params[:search] unless params[:search].blank?
      paginate page: params[:page] || 1, per_page: 10
      order_by params[:order], params[:sort] unless params[:order].blank?
    end
    @stocks = @search.results
  end

  # GET /stocks/1 or /stocks/1.json
  def show
  end

  # GET /stocks/new
  def new
    @stock = Stock.new
  end

  # GET /stocks/1/edit
  def edit
  end

  # POST /stocks or /stocks.json
  def create
    @stock = Stock.new(stock_params)

    respond_to do |format|
      if @stock.save
        format.html { redirect_to @stock, notice: "Stock was successfully created." }
        format.json { render :show, status: :created, location: @stock }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stocks/1 or /stocks/1.json
  def update
    respond_to do |format|
      if @stock.update(stock_params)
        format.html { redirect_to @stock, notice: "Stock was successfully updated." }
        format.json { render :show, status: :ok, location: @stock }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stocks/1 or /stocks/1.json
  def destroy
    @stock.destroy!

    respond_to do |format|
      format.html { redirect_to stocks_path, status: :see_other, notice: "Stock was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  def download_qr
    respond_to do |format|
      format.svg do
        render inline: @stock.generate_qr_code_svg
      end
      
      format.png do
        send_data @stock.generate_qr_code_png.to_s, 
                  filename: "stock-#{@stock.reference}-qr.png",
                  type: 'image/png',
                  disposition: 'attachment'
      end
    end
  end
  def assign_to_user
    @item_location = @stock.build_item_location(
      status: :assigned,
      user_id: params[:user_id],
      assigned_at: Time.current,
      return_date: params[:return_date],
      notes: params[:notes]
    )

    if @item_location.save
      redirect_to @stock.item, notice: 'Stock asignado correctamente.'
    else
      redirect_to @stock.item, alert: 'Error al asignar el stock.'
    end
  end

  def return_from_user
    @item_location = @stock.item_location
  
    return redirect_to @stock.item, alert: 'El stock no tiene una ubicación asignada.' if @item_location.nil?
    return redirect_to @stock.item, alert: 'El stock no está asignado a un usuario.' unless @item_location.assigned?
    return redirect_to @stock.item, alert: 'Debe seleccionar una sección.' if params[:section_id].blank?
  
    if @item_location.update(
      status: :in_storage,
      section_id: params[:section_id],
      return_date: Time.current,
      notes: "#{@item_location.notes}\nDevuelto: #{params[:return_notes]}"
    )
      redirect_to @stock.item, notice: 'Stock devuelto correctamente.'
    else
      redirect_to @stock.item, alert: 'Error al devolver el stock: ' + @item_location.errors.full_messages.join(', ')
    end
  end
  def move_to_section
    @item_location = @stock.item_location || @stock.build_item_location
    
    @item_location.assign_attributes(
      status: :in_storage,
      section_id: params[:section_id],
      assigned_at: Time.current,
      user_id: nil,
      notes: params[:notes]
    )

    if @item_location.save
      redirect_to @stock.item, notice: 'Stock movido correctamente.'
    else
      redirect_to @stock.item, alert: 'Error al mover el stock.'
    end
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stock
      @stock = Stock.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def stock_params
      params.require(:stock).permit(:item_id, :reference, :description, :active, :entry_date)
    end
end
