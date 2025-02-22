class InputReportStocksController < ApplicationController
  before_action :set_input_report_stock, only: %i[ show edit update destroy ]

  # GET /input_report_stocks or /input_report_stocks.json
  def index
    @input_report_stocks = InputReportStock.all
  end

  # GET /input_report_stocks/1 or /input_report_stocks/1.json
  def show
  end

  # GET /input_report_stocks/new
  def new
    @input_report_stock = InputReportStock.new
  end

  # GET /input_report_stocks/1/edit
  def edit
  end

  # POST /input_report_stocks or /input_report_stocks.json
  def create
    @input_report_stock = InputReportStock.new(input_report_stock_params)

    respond_to do |format|
      if @input_report_stock.save
        format.html { redirect_to @input_report_stock, notice: "Input report stock was successfully created." }
        format.json { render :show, status: :created, location: @input_report_stock }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @input_report_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /input_report_stocks/1 or /input_report_stocks/1.json
  def update
    respond_to do |format|
      if @input_report_stock.update(input_report_stock_params)
        format.html { redirect_to @input_report_stock, notice: "Input report stock was successfully updated." }
        format.json { render :show, status: :ok, location: @input_report_stock }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @input_report_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /input_report_stocks/1 or /input_report_stocks/1.json
  def destroy
    @input_report_stock.destroy!

    respond_to do |format|
      format.html { redirect_to input_report_stocks_path, status: :see_other, notice: "Input report stock was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_input_report_stock
      @input_report_stock = InputReportStock.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def input_report_stock_params
      params.require(:input_report_stock).permit(:input_report_id, :stock_id, :section_id, :notes)
    end
end
