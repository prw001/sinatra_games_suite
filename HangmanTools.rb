module HangmanTools

	module Tools
		def get_word
			dict = load_dict
			return dict[rand(dict.length - 1)]
		end

		def load_dict
			dict = []
			#picks words between 5 and 12 chars in length
			File.foreach('./public/resources/dict.txt') do |line|
				if line.length >= 7 && line.length <= 14
					dict << (line.gsub(/\n\r/, ' ').strip.downcase)
				end
			end
			return dict
		end

		def create_slots(word, length)
			open_slots = {}
			length.times do |index|
				letter = word[index]
				open_slots[letter] = false
			end
			return open_slots
		end
	end

	class Game

		include Tools

		attr_reader :secret_word
		attr_reader :guess_slots
		attr_reader :guessed_letters
		attr_reader :turns_left

		def initialize
			@secret_word = get_word
			@guess_slots = create_slots(secret_word, secret_word.length)
			@guessed_letters = []
			@turns_left = (secret_word.length/2 + 2)
		end

		def guess(letter)
			if @guess_slots.keys.include? letter
				@guess_slots[letter] = true
			end

			if !(@guess_slots.keys.include? letter) &&
			   !(@guessed_letters.include? letter)
			   		@turns_left -= 1
			end

			if !(@guessed_letters.include? letter)
			   		@guessed_letters << letter
			end
		end

		def solved?
			@guess_slots.values.all? true ? true : false
		end
	end
end