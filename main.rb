require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

get '/' do
  erb :set_name
end

post '/set_name' do
  puts "Hello mi amigo"
  session[:set_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  session[:deck] = [['2','H'],['3','D']]
  session[:player_cards] = []
  session[:player_cards] << session[:deck].pop

  erb :game
end





