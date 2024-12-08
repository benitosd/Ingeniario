class SearchController < ApplicationController
    def query
        # Get the search terms from the q parameter and do a search
        # as we seen in the previous part of the article.
        search = User.search do
          fulltext params[:q] # Full text search
        end
    
        respond_to do |format|
          format.json do
            # Create an array from the search results.
            results = search.results.map do |tree|
              # Each element will be a hash containing only the title of the article.
              # The title key is used by typeahead.js.
              { code: tree.code ,
                email: tree.email,
                
                
                
                }
            end
            render json: results
          end
        end
      end
end
