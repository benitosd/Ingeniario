class UsersController < ApplicationController
        
    def index
          @search = User.all.search do
         fulltext params[:search] unless params[:search].blank?
         paginate :page => params[:page] || 1, :per_page => 10
         order_by params[:order], params[:sort] unless params[:order].blank?
       end
       @users = @search.results
     end
end
