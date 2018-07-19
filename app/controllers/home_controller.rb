class HomeController < ApplicationController
  def index
	@stocks = Stock.where(user_id: current_user.id).all
  	@add_stock = Stock.new
  end
end