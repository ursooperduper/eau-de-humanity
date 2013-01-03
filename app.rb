# app.rb
require 'rubygems'
require 'sinatra'
require 'haml'
require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'

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
end

# Create or upgrade all tables at once, like magic
DataMapper.auto_upgrade!

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
		@card.cardtext.gsub!(/\[\]/, '_______________')
		@card.cardtext.gsub!(/\[b\]/, '<br><br>')
		haml :show
	else
		redirect('/list')
	end
end

get '/delete/:id' do
	card = Card.get(params[:id])
	unless card.nil?
		card.destroy
	end
	redirect('/list')
end



