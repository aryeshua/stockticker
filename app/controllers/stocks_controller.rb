class StocksController < ApplicationController
	def show

	# Initialioze Left side bar (Stock Watch List)
	@stocks = Stock.where(user_id: current_user.id).all
	@add_stock = Stock.new			

  	# Selects the selected stock belonging to current user from parameters

  	ticker = params[:ticker]
  	stock_select = ticker.to_s
  	
  	# Utilizes gem to get information based on stock ticker value

  	stock_to_json = StockQuote::Stock.company(stock_select).to_json
  	stock_chart_to_json = StockQuote::Stock.batch('chart',stock_select,'3m').to_json

  	# Allows us to display data in view

	@stock_info = JSON.parse(stock_to_json)
	@stock_chart = JSON.parse(stock_chart_to_json)

	# Load Up Data for Chart
	stock_chart_to_json_for_graph = StockQuote::Stock.batch('chart',stock_select,'1m').to_json
	@stock_graph = JSON.parse(stock_chart_to_json_for_graph)

	array_date = []
	array_price = []

	@stock_graph['chart'].each do |stock|
		array_date.push(stock['date'])
		array_price.push(stock['close'])
	end


	# Chart

	@chart = LazyHighCharts::HighChart.new('graph') do |f|

    f.title({ text: "Price (last 30 days)"})

    f.options[:xAxis][:categories] = array_date

    f.series(:type=> 'spline',:name=> 'Average', 

             :data=> array_price)

	end
end

	def create
		@stock = Stock.new(stock_params)
		@stock.user_id = current_user.id
		@stock.ticker = @stock.ticker.upcase

		stock_to_json = StockQuote::Stock.company(@stock.ticker)

		if !stock_to_json.present?
			redirect_to :controller => 'home', :action => 'index' 
			flash[:alert] = "Stock symbol does not exist."
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
