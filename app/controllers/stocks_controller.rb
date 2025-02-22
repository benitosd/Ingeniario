class StocksController < ApplicationController
  before_action :set_stock, except: [:bulk_new, :bulk_create, :index, :new, :create, :find_by_reference]
  before_action :set_item, only: [:new, :create, :bulk_new, :bulk_create]
  before_action :set_item_from_stock, only: [:edit, :update]
  before_action :load_sections, only: [:new, :edit, :create, :update, :bulk_new]

  ESTADOS_TRADUCIDOS = {
    'storage' => 'in_storage',
    'assigned' => 'assigned',
    'repair' => 'en_reparacion',
    'broken' => 'roto',
    'missing' => 'desaparecido'
  }.freeze

  # GET /stocks or /stocks.json
  def index
    @search = Stock.search do
      # Búsqueda de texto
      fulltext params[:search] if params[:search].present?
      
      # Filtro por estado del stock
      if params[:fq].present?
        status = params[:fq].split(':').last
        with(:item_location_status, status)
      end
      
      # Filtro por fecha
      if params[:date_filter].present?
        with(:entry_date).greater_than(params[:date_filter].to_date)
      end

      # Ordenación
      if params[:order].present?
        direction = params[:sort] || 'asc'
        case params[:order]
        when 'date_dt'
          order_by :entry_date, direction
        when 'stock_status_ss'
          order_by :item_location_status, direction
        else
          order_by :entry_date, :desc
        end
      else
        order_by :entry_date, :desc
      end

      paginate page: params[:page], per_page: 25
    end

    @stocks = @search.results
    
    Rails.logger.debug "[INDEX] Total resultados encontrados: #{@search.total}"
    Rails.logger.debug "[INDEX] Estados de los resultados: #{@stocks.map { |s| s.item_location&.status }.compact}"
  
    if params[:status].present? && @stocks.empty?
      flash.now[:alert] = "No se encontraron stocks con el estado '#{params[:status]}'"
    end
  end
  def search
    query = params[:query].to_s.strip
    
    @search = Stock.search do
      fulltext query do
        fields(:reference, :item_name)
      end
      with(:available, true)
      paginate(page: 1, per_page: 10)
    end
  
    results = @search.results.map do |stock|
      {
        id: stock.id,
        reference: stock.reference,
        item_name: stock.item_name,
        available: stock.available
      }
    end
  
    render json: results
  end
  # GET /stocks/1 or /stocks/1.json
  def show
  end

  # GET /stocks/new
  def new
    @stock = @item.stocks.build
    @stock.entry_date = Time.current
  end

  # GET /stocks/1/edit
  def edit
  end

  # POST /stocks or /stocks.json
  def create
    @stock = @item.stocks.build(stock_params)
    
    respond_to do |format|
      if @stock.save
        # Crear ItemLocation si se seleccionó una sección
        if params[:stock][:section_id].present?
          @stock.create_item_location(
            section_id: params[:stock][:section_id],
            status: :in_storage,
            user: current_user,
            assigned_at: Time.current,
            notes: "Stock creado y almacenado en sección"
          )
        end

        format.html { redirect_to item_path(@item), notice: 'Stock creado correctamente.' }
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
        # Actualizar o crear ItemLocation si se seleccionó una sección
        if params[:stock][:section_id].present?
          if @stock.item_location.present?
            @stock.item_location.update(
              section_id: params[:stock][:section_id],
              status: :in_storage,
              notes: "#{@stock.item_location.notes}\nStock reubicado en sección"
            )
          else
            @stock.create_item_location(
              section_id: params[:stock][:section_id],
              status: :in_storage,
              user: current_user,
              assigned_at: Time.current,
              notes: "Stock almacenado en sección"
            )
          end
        end

        format.html { redirect_to stock_path(@stock), notice: 'Stock actualizado correctamente.' }
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

  def find_by_reference
    Rails.logger.debug "Buscando stock con referencia: #{params[:reference]}"
    @stock = Stock.find_by(reference: params[:reference])
    
    Rails.logger.debug "Stock encontrado: #{@stock.inspect}"
    Rails.logger.debug "Item location: #{@stock&.item_location.inspect}"
    
    if @stock && (@stock.item_location.nil? || @stock.item_location.in_storage?)
      response_data = {
        id: @stock.id,
        reference: @stock.reference,
        item_name: @stock.item.name,
        available: true
      }
      Rails.logger.debug "Enviando respuesta: #{response_data.inspect}"
      render json: response_data
    else
      Rails.logger.debug "Stock no disponible"
      render json: { available: false }
    end
  rescue => e
    Rails.logger.error "Error en find_by_reference: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { available: false, error: e.message }, status: :internal_server_error
  end

  def download_qr
    respond_to do |format|
      @stock = Stock.find(params[:id])
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

  def store
    handle_status_change(:store!)
  end

  def repair
    handle_status_change(:repair!)
  end

  def mark_as_broken
    handle_status_change(:mark_as_broken!)
  end

  def mark_as_missing
    if @stock.assigned?
      ActiveRecord::Base.transaction do
        @stock.item_location.mark_as_missing!
        
        @stock.stock_movements.create!(
          user: current_user,
          action: :mark_as_missing,
          status: :desaparecido,
          notes: "Stock marcado como desaparecido"
        )
      end

      redirect_to @stock, notice: 'Stock marcado como desaparecido.'
    else
      redirect_to @stock, alert: 'El stock no puede ser marcado como desaparecido en su estado actual.'
    end
  end

  def assign_section
    section = Section.find(params[:section_id])
    notes = params[:notes].presence || "Stock movido a nueva ubicación"
    
    if @stock.item_location.present?
      @stock.item_location.update!(
        section: section,
        notes: "#{@stock.item_location.notes}\n#{Time.current.strftime('%d/%m/%Y %H:%M')} - #{notes}"
      )
    else
      @stock.create_item_location(
        section: section,
        status: :in_storage,
        user: current_user,
        assigned_at: Time.current,
        notes: notes
      )
    end

    respond_to do |format|
      format.html { redirect_to @stock, notice: 'Ubicación actualizada correctamente.' }
      format.json { render :show, status: :ok, location: @stock }
    end
  end

  def bulk_new
    @item = Item.find(params[:item_id])
  end

  def bulk_create
    @item = Item.find(params[:item_id])
    quantity = params[:quantity].to_i
    
    ActiveRecord::Base.transaction do
      quantity.times do
        stock = @item.stocks.create!(
          entry_date: params[:entry_date],
          description: params[:description],
          active: true
        )
        
        stock.create_item_location(
          section_id: params[:section_id],
          status: :in_storage,
          user: current_user,
          assigned_at: Time.current,
          notes: params[:notes]
        )
      end
    end

    redirect_to item_path(@item), notice: "Se crearon #{quantity} stocks exitosamente"
  rescue => e
    redirect_to item_path(@item), alert: "Error al crear los stocks: #{e.message}"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stock
      @stock = Stock.find(params[:id])
    end

    def set_item
      @item = Item.find(params[:item_id]) if params[:item_id]
    end

    def set_item_from_stock
      @item = @stock.item if @stock
    end

    def load_sections
      @sections = Section.all
    end

    # Only allow a list of trusted parameters through.
    def stock_params
      if params[:action] == 'update'
        params.require(:stock).permit(:reference, :description, :entry_date, :active)
      else
        params.require(:stock).permit(:item_id, :reference, :description, :entry_date, :active)
      end
    end

    def status_text(status)
      case status
      when 'assigned' then 'Asignado'
      when 'repair' then 'En Reparación'
      when 'broken' then 'Roto'
      when 'missing' then 'Desaparecido'
      when 'storage' then 'Almacenado'
      else status.to_s.humanize
      end
    end

    def handle_status_change(action)
      location = @stock.item_location

      unless location
        redirect_to @stock, alert: 'El stock no tiene una ubicación asignada.'
        return
      end

      begin
        if location.send(action)
          redirect_to @stock, notice: mensaje_exito(action)
        else
          redirect_to @stock, 
                    alert: "No se pudo cambiar el estado. Estado actual: #{location.status_text}"
        end
      rescue => e
        Rails.logger.error "Error cambiando estado del stock #{@stock.id}: #{e.message}"
        redirect_to @stock, 
                  alert: "Error al cambiar el estado: #{mensaje_error(location.status_text, action)}"
      end
    end

    def mensaje_exito(action)
      case action
      when :store!
        'Stock almacenado correctamente'
      when :repair!
        'Stock enviado a reparación'
      when :mark_as_broken!
        'Stock marcado como roto'
      end
    end

    def mensaje_error(estado_actual, action)
      case action
      when :store!
        "Solo se pueden almacenar stocks en estado 'Asignado' o 'En Reparación'. Estado actual: #{estado_actual}"
      when :repair!
        "Solo se pueden enviar a reparación stocks en estado 'Asignado' o 'Almacenado'. Estado actual: #{estado_actual}"
      when :mark_as_broken!
        "Solo se pueden marcar como rotos stocks en estado 'En Reparación'. Estado actual: #{estado_actual}"
      end
    end
end
