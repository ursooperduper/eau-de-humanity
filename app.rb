# app.rb
require 'rubygems'
require 'sinatra'
require 'haml'
require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'
require 'dm-aggregates'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/assets/db/cards.db")

class Card
	include DataMapper::Resource

	property :id, 					Serial
	property :cardtext,			Text
	property :color,				String
	property :set, 					String
	property :tags, 				Text
	property :draw,					Integer
	property :pick, 				Integer
	property :created_at,		DateTime
	property :updated_at, 	DateTime

	def cleanUp
		cardtext.gsub!(/\[\]/, '_______________')
		cardtext.gsub!(/\[b\]/, '<br/>')
		cardtext.gsub!(/\[r\]/, '&reg;')
		cardtext.gsub!(/\[tm\]/, '&trade;')
		return self
	end

end

# Create or upgrade all tables at once, like magic
DataMapper.auto_upgrade!

configure do 
	set :show_exceptions, false 
end 

error do 
	"Y U NO WORK?"
end

not_found do 
	"Whoops! You requested a route that wasn't available." 
end

get '/' do
	@title = 'Hello world!'
end

get '/list' do
	@title = "List Cards"
	@cards = Card.all(:order => [:created_at.desc])
	haml :list
end


get '/new' do
	@title = "Add new card"
	haml :new
end

post '/create' do
	@card = Card.new(params[:card])
	if @card.save
		redirect "/show/#{@card.id}"
	else
		redirect('/list')
	end
end

get '/show/:id' do
	@card = Card.get(params[:id])
	if @card
		@card.cleanUp
		haml :show
	else
		redirect('/list')
	end
end

get '/edit/:id' do
	@title = "Edit Card"
	@card = Card.get(params[:id])
	haml :edit
end

post '/update/:id' do
  @card = Card.get(params[:id])
  @card.update(params[:card])
  redirect "/show/#{@card.id}"
end

get '/delete/:id' do
	card = Card.get(params[:id])
	unless card.nil?
		card.destroy
	end
	redirect('/list')
end

get '/info' do
	@card_count = Card.count
	@b_card_count = Card.count(:conditions => { :color => "b" }) 
	@w_card_count = Card.count(:conditions => { :color => "w" })
	haml :info
end

get '/random_hand/?' do
	@title = "Eau de Humanity"
	
	b_cards = Card.all(:color => "b").shuffle!
	b_cards.map! {|bc| bc.cleanUp}

	w_cards = Card.all(:color => "w").shuffle!
	w_cards.map! {|wc| wc.cleanUp}

	@b_card = b_cards[0]
	@wh_playcards = []
	i = 0
	while i < @b_card.pick
  	@wh_playcards.push(w_cards[i])
  	i += 1
	end
	haml :random
end
