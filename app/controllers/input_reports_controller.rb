class InputReportsController < ApplicationController
  before_action :set_output_report, only: [:new, :create]
  before_action :set_input_report, only: [:show, :edit, :update, :destroy, 
                                        :store_stock, :repair_stock, :mark_as_broken_stock,
                                        :approve, :mark_as_missing_stock]

  # GET /input_reports or /input_reports.json
  def index
    @input_reports = InputReport.all
  end

  # GET /input_reports/1 or /input_reports/1.json
  def show
    @input_report_stocks = @input_report.input_report_stocks.includes(stock: :item)
  end

  # GET /input_reports/new
  def new
    @input_report = InputReport.new(
      output_report: @output_report,
      user: current_user,
      date: Date.current
    )
    
    # Construir input_report_stocks para todos los stocks del output_report
    @output_report.output_report_stocks.each do |output_stock|
      input_report_stock = @input_report.input_report_stocks.build(
        stock: output_stock.stock,
        section: output_stock.stock.item_location&.section
      )
      # Almacenar el estado original del stock
      input_report_stock.original_status = output_stock.stock.item_location&.status
    end

    # Cargar datos necesarios para el formulario
    load_form_data
  end

  # GET /input_reports/1/edit
  def edit
    @output_report = @input_report.output_report
    load_form_data
  end

  # POST /input_reports or /input_reports.json
  def create
    @input_report = InputReport.new(input_report_params)
    @input_report.output_report = @output_report

    respond_to do |format|
      if @input_report.save
        format.html { redirect_to @input_report, notice: 'Informe de entrada creado correctamente.' }
        format.turbo_stream { redirect_to @input_report, notice: 'Informe de entrada creado correctamente.' }
      else
        load_form_data
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace(
            "input_report_form",
            partial: "form",
            locals: { input_report: @input_report }
          )
        }
      end
    end
  end

  # PATCH/PUT /input_reports/1 or /input_reports/1.json
  def update
    respond_to do |format|
      if @input_report.update(input_report_params)
        format.html { redirect_to @input_report, notice: 'Informe de entrada actualizado correctamente.' }
        format.turbo_stream { redirect_to @input_report, notice: 'Informe de entrada actualizado correctamente.' }
      else
        load_form_data
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace(
            "input_report_form",
            partial: "form",
            locals: { input_report: @input_report }
          )
        }
      end
    end
  end

  # DELETE /input_reports/1 or /input_reports/1.json
  def destroy
    @input_report.destroy
    respond_to do |format|
      format.html { 
        flash[:notice] = 'Informe de entrada eliminado correctamente.'
        redirect_to input_reports_url
      }
      format.turbo_stream {
        flash.now[:notice] = 'Informe de entrada eliminado correctamente.'
        render turbo_stream: turbo_stream.append("body", 
          "<script>
            window.location.href = '#{input_reports_path}';
          </script>".html_safe
        )
      }
    end
  end

  def store_stock
    handle_stock_status_change(:store!)
  end

  def repair_stock
    handle_stock_status_change(:repair!)
  end

  def mark_as_broken_stock
    handle_stock_status_change(:mark_as_broken!)
  end

  def mark_as_missing_stock
    handle_stock_status_change(:mark_as_missing!)
  end

  def approve
    respond_to do |format|
      ActiveRecord::Base.transaction do
        if @input_report.approve!
          # Procesar solo los stocks que están en estado asignado
          @input_report.input_report_stocks.includes(stock: :item_location).each do |input_stock|
            stock = input_stock.stock
            location = stock.item_location

            # Solo cambiar el estado si está asignado, mantener el resto como están
            if location&.status == 'assigned'
              begin
                location.store!
                Rails.logger.info "Stock #{stock.id} cambiado de asignado a almacenado"
              rescue => e
                Rails.logger.error "Error cambiando estado del stock #{stock.id}: #{e.message}"
              end
            else
              Rails.logger.info "Stock #{stock.id} mantiene su estado actual: #{location&.status}"
            end
          end

          format.html { redirect_to @input_report, notice: 'Informe de entrada aprobado correctamente.' }
          format.turbo_stream { redirect_to @input_report, notice: 'Informe de entrada aprobado correctamente.' }
        else
          format.html { redirect_to @input_report, alert: "No se pudo aprobar el informe: #{@input_report.errors.full_messages.join(', ')}" }
          format.turbo_stream { redirect_to @input_report, alert: "No se pudo aprobar el informe: #{@input_report.errors.full_messages.join(', ')}" }
        end
      end
    rescue => e
      format.html { redirect_to @input_report, alert: "Error al aprobar el informe: #{e.message}" }
      format.turbo_stream { redirect_to @input_report, alert: "Error al aprobar el informe: #{e.message}" }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_output_report
      @output_report = OutputReport.find(params[:output_report_id])
    end

    def set_input_report
      @input_report = InputReport.find(params[:id])
    end

    def handle_stock_status_change(action)
      stock = Stock.find(params[:stock_id])
      location = stock.item_location

      unless location
        redirect_to @input_report, alert: 'El stock no tiene una ubicación asignada.'
        return
      end

      begin
        case action
        when :mark_as_broken!
          # Solo permitir marcar como roto si está en reparación
          unless location.status == 'en_reparacion'
            redirect_to @input_report, 
                      alert: "Solo se pueden marcar como rotos stocks en estado 'En Reparación'. Estado actual: #{location.status_text}"
            return
          end
        when :mark_as_missing!
          # Solo permitir marcar como desaparecido si está asignado
          unless location.status == 'assigned'
            redirect_to @input_report, 
                      alert: "Solo se pueden marcar como desaparecidos stocks en estado 'Asignado'. Estado actual: #{location.status_text}"
            return
          end
        end

        if location.send(action)
          redirect_to @input_report, notice: mensaje_exito(action)
        else
          redirect_to @input_report, 
                      alert: "No se pudo cambiar el estado. Estado actual: #{location.status_text}"
        end
      rescue => e
        Rails.logger.error "Error cambiando estado del stock #{stock.id}: #{e.message}"
        redirect_to @input_report, 
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
      when :mark_as_missing!
        'Stock marcado como desaparecido'
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
      when :mark_as_missing!
        "Solo se pueden marcar como desaparecidos stocks en estado 'Asignado'. Estado actual: #{estado_actual}"
      end
    end

    # Only allow a list of trusted parameters through.
    def input_report_params
      params.require(:input_report).permit(
        :date,
        :notes,
        :user_id,
        input_report_stocks_attributes: [:id, :stock_id, :section_id, :notes]
      )
    end

    def load_form_data
      # Obtener los IDs de los stocks que ya han sido devueltos
      returned_stock_ids = @output_report.input_reports.joins(:input_report_stocks)
                                       .where.not(status: :cancelled)
                                       .pluck('input_report_stocks.stock_id')

      # Filtrar los stocks que aún no han sido devueltos
      @available_stocks = @output_report.stocks
                                      .joins(:item_location)
                                      .where(item_locations: { status: :assigned })
                                      .where.not(id: returned_stock_ids)

      @available_sections = Section.includes(:warehouse).all
      @users = User.order(:email)
    end
end
