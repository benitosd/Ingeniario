class OutputReportsController < ApplicationController
    before_action :set_output_report, only: [:show, :edit, :update, :destroy, :approve]
  
    def index
      @output_reports = OutputReport.all.includes(:user).order(created_at: :desc)
    end
  
    def show
      @output_report_stocks = @output_report.output_report_stocks.includes(stock: :item)
    end
  
    def new
        @output_report = OutputReport.new
        @available_stocks = available_stocks_for_selection
      end
      
      def edit
        @available_stocks = Stock.left_joins(:item_location)
                                .where('item_locations.id IS NULL OR item_locations.status = ?', 
                                       ItemLocation.statuses[:in_storage])
      end
  
      def create
        @output_report = OutputReport.new(output_report_params)
        
        Rails.logger.debug "Parámetros recibidos: #{output_report_params.inspect}"
        Rails.logger.debug "Errores: #{@output_report.errors.full_messages}" unless @output_report.valid?
        
        if @output_report.save
          redirect_to @output_report, notice: 'Informe de salida creado correctamente.'
        else
          @available_stocks = available_stocks_for_selection
          flash[:alert] = @output_report.errors.full_messages.join(', ')
          render new_output_report_path, status: :unprocessable_entity
        end
      end
  
    def update
      if @output_report.update(output_report_params)
        redirect_to @output_report, notice: 'Informe de salida actualizado correctamente.'
      else
        @available_stocks = Stock.joins(:item_location)
                               .where(item_locations: { status: :in_storage })
                               .or(Stock.where.missing(:item_location))
        render :edit
      end
    end
  
    def destroy
      @output_report.destroy
      redirect_to output_reports_url, notice: 'Informe de salida eliminado correctamente.'
    end
  
    def approve
      if @output_report.approve!
        redirect_to @output_report, notice: 'Informe de salida aprobado correctamente.'
      else
        redirect_to @output_report, alert: 'Error al aprobar el informe de salida.'
      end
    end
  
    private
  
    def set_output_report
      @output_report = OutputReport.find(params[:id])
    end
  
    def output_report_params
      params.require(:output_report).permit(
        :user_id, 
        :date, 
        :reason,
        output_report_stocks_attributes: [:id, :stock_id, :return_date, :notes, :_destroy]
      )
    end
    def available_stocks_for_selection
        base_query = Stock.left_outer_joins(:item_location)
        base_query.where(item_locations: { id: nil })
                 .or(base_query.where(item_locations: { status: ItemLocation.statuses[:in_storage] }))
      end
  end