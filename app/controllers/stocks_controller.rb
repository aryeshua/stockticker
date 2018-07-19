class StocksController < ApplicationController
	def show

  	# Selects the selected stock belonging to current user from parameters

  	ticker = params[:ticker]
  	stock_select = ticker.to_s
  	
  	# Utilizes gem to get information based on stock ticker value

  	stock_to_json = StockQuote::Stock.company(stock_select).to_json
  	stock_chart_to_json = StockQuote::Stock.batch('chart',stock_select,'1m').to_json

  	# Allows us to display data in view

	@stock_info = JSON.parse(stock_to_json)
	@stock_chart = JSON.parse(stock_chart_to_json)

	# Let's calculate simple moving average
	sum = 0
	number_of_days = @stock_chart['chart'].count

	@stock_chart['chart'].each do |stock|
		sum = sum + stock['close']
	end

	@sum = (sum/number_of_days).round(2)

	end

	def create
		@stock = Stock.new(stock_params)
		@stock.user_id = current_user.id
		@stock.ticker = @stock.ticker.upcase

		stock_to_json = StockQuote::Stock.company(@stock.ticker)

		if !stock_to_json.present?
			redirect_to :controller => 'home', :action => 'index' 
		else
			@stock.save
			redirect_to :controller => 'home', :action => 'index' 
		end

	
	
		
	end

	def destroy
		@stock = Stock.find(params[:id])
		@stock.destroy
		redirect_to :controller => 'home', :action => 'index' 
	end

private

	def stock_params
		params.require(:stock).permit(:user_id, :ticker)
	end
end
