require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/reloader'
require_relative 'HangmanTools.rb'
require_relative 'MastermindTools.rb'
require_relative 'CipherTools.rb'

set :sessions, true

use Rack::Session::Pool

cc_title = 'CAESAR CIPHER'
instructions = "<strong>1.</strong> Type a message in the field below.<br>
<strong>2.</strong> Then select an encryption key from the dropdown menu.<br>
<strong>3.</strong> Finally, click 'encrypt message' to receive your newly encrypted message below!<br>"
default_message = 'no message'

hm_title = 'Hangman'
blank = '__'
letter_bank = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l',
			   'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
			   'y', 'z']

mm_title = 'MASTERMIND'


module CaesarTools
	extend CipherTools
end

module MmTools
	extend MastermindTools
end

module HmTools
	extend HangmanTools
end

include CaesarTools
include MmTools
include HmTools

get '/' do 
	erb :suite_index
end

get '/Caesar' do 
	new_message = false
	erb :cc_index, :locals => {:title => cc_title,
							   :instructions => instructions,
							   :default_message => default_message,
							   :new_message => new_message}
end

get '/Caesar/cipher' do 
	message = params["message"]
	key = params["encrypt_key"].to_i
	ciphered_message = CaesarTools::cipher(message, key)
	erb :cc_index, :locals => {:title => cc_title,
							   :instructions => instructions,
							   :new_message => ciphered_message}
end

get '/Hangman/newgame' do 
	session[:game] = HangmanTools::Game.new
	erb :hm_play, layout: :hm_index,
	    :locals => {:title => hm_title, :game => session[:game],
	    		    :blank => blank, :letter_bank => letter_bank}
end

get '/Hangman/guess' do 
	letter = params["char"]
	session[:game].guess(letter)
	if session[:game].turns_left > 0 && !(session[:game].solved?)
		erb :hm_play, layout: :hm_index,
			:locals => {:title => hm_title, :game => session[:game],
					    :blank => blank, :letter_bank => letter_bank}
	else
		redirect '/Hangman/gameover'
	end
end

get '/Hangman/gameover' do 
	erb :hm_gameover, layout: :hm_index,
		:locals => {:title => hm_title, :game => session[:game]}
end

get '/Mastermind' do 
	erb :mm_home, layout: :mm_index, :locals => {:title => mm_title}
end

get '/Mastermind/newgame' do 
	session[:game] = MastermindTools::Game.new
	erb :mm_play, layout: :mm_index,
		:locals => {:title => mm_title, :game => session[:game]}
end

get '/Mastermind/guess' do 
	last_guess = []

	params.keys.each do |key|
		last_guess << params[key].downcase
	end

	unless last_guess.length == 0
		session[:game].add_guess(last_guess)
	end

	if session[:game].turns_left == 0 || session[:game].game_over
		redirect '/Mastermind/gameover'
	end

	erb :mm_play, layout: :mm_index,
		:locals => {:title => mm_title, :game => session[:game]}
end

get '/Mastermind/gameover' do 
	if session[:game].cracked
		win_or_lose = "Congratulations! You've cracked the code!"
	else
		win_or_lose = "You have failed to crack the code."
	end

	erb :mm_gameover, layout: :mm_index,
		:locals => {:title => mm_title, :game => session[:game],
					:win_or_lose => win_or_lose}
end