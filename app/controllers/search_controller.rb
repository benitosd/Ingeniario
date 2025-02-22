# app/controllers/search_controller.rb
class SearchController < ApplicationController
  def query
    search = Stock.search do
      fulltext params[:q]
      with(:active, true)  # Solo stocks activos
    end

    respond_to do |format|
      format.json do
        results = search.results.map do |stock|
          {
            id: stock.id,
            reference: stock.reference,
            description: stock.description,
            item: {
              id: stock.item.id,
              name: stock.item.name
            }
          }
        end
        render json: results
      end
    end
  end
end