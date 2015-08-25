require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

get '/' do
  if session[:set_name]
  	redirect '/game'
  else
  	redirect '/set_name'
    
  end
end

helpers do
  def calculate_total(cards)
    arr = cards.map{|element| element[1]}

    total = 0
    arr.each do |a|
      if a == "A"
        total += 11
      else
        total += a.to_i == 0 ? 10 : a.to_i
      end
    end
    
    arr.select {|element| element == "A"}.count.times do
      break if total <= 21
      total -= 10
    end
    total
  end

  def card_image(card)
    suit = case card[0]
      when 'D' then "diamonds"
      when 'H' then "hearts"
      when 'S' then "spades"
      when 'C' then "clubs"
    end

    value= card[1]
    if ['J','K','Q','A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end

    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
  end

  def winner!(msg)
    @play_again = true
    @success = "<strong> #{session[:set_name]} wins!</strong> #{msg}"
    @show_hit_or_stay_buttons = false
  end

  def loser!(msg)
    @play_again = true
    @error = "<strong> #{session[:set_name]} loses!</strong> #{msg}"
    @show_hit_or_stay_buttons = false
  end

  def tie!(msg)
    @play_again = true
    @success = "<strong> It's a tie! </strong> #{msg}"
    @show_hit_or_stay_buttons = false
  end
end

before do
  @show_hit_or_stay_buttons = true
end


get '/set_name' do 
  erb :set_name
end

post '/set_name' do
  if params[:set_name].empty?
    @error = "Enter a fucking user name dipshit"
    halt erb(:set_name)
  end

  session[:set_name] = params[:set_name]
  redirect '/game'
end

get '/game' do
  session[:turn] = session[:set_name]
  # Set up initial game values
  # Render the template
  # deck
  suit = ['H','D','C','S']
  values = ['2','3','4','5','6','7','8','9','10','J','Q','K','A']
  session[:deck] = suit.product(values).shuffle!
  # deal cards
  	#dealer cards
  session[:dealer_cards] = []
  	#player cards
  session[:player_cards] = []

  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  
  player_total = calculate_total(session[:player_cards])
  if player_total == 21
    winner!
  elsif player_total > 21
    loser!
  end
  erb :game
end

post '/game/player/stay' do
  @success = "#{session[:set_name]} have chosen to stay"
  @show_hit_or_stay_buttons = false
  redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = "dealer"
  @show_hit_or_stay_buttons = false

  dealer_total = calculate_total(session[:dealer_cards])
  if dealer_total == 21
    loser!
  elsif dealer_total > 21
    winner!
  elsif dealer_total >= 17
    redirect '/game/compare'
  else
    @show_dealer_hit_button = true
  end
    
  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @show_hit_or_stay_buttons = false

  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total < dealer_total
    loser!("#{session[:set_name]} stayed at #{player_total} and the dealer stayed at #{dealer_total}")
  elsif player_total > dealer_total
    winner!("#{session[:set_name]} stayed at #{player_total} and the dealer stayed at #{dealer_total}")
  else
    tie!("Both dealer and #{session[:set_name]} stayed at #{player_total}")
  end
  erb :game
end

get '/game_over' do
  erb :game_over
end








