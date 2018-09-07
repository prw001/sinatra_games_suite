module MastermindTools

  module Tools

  	def num_to_color(num)
      	case num
      	when 1
        		return 'r'
      	when 2
        		return 'o'
      	when 3
        		return 'y'
      	when 4
        		return 'g'
      	when 5
      	  	return 'b'
      	else
      	  	return 'v'
      	end
    	end

    	def generate_code
    		code = []
    		4.times do 
    			code << num_to_color(rand(1..6))
    		end
    		return code
    	end

    	def generate_hints(guess, code, colors)
    		guess_copy = guess.dup
    		code_copy = code.dup
    		hints = []
    		index = 0
    		#check for color and position matches, remove matches
    		while index < code_copy.length
    			if code_copy[index] == guess_copy[index]
    				hints << '+'
    				code_copy.slice!(index, 1)
    				guess_copy.slice!(index, 1)
    			else
    				index += 1
    			end
    		end
    		#check remaining elements for color matches
    		colors.each do |color|
    			c = color.downcase
    			if (code_copy.include? c) &&
    			   (guess_copy.include? c)
    			   		if guess_copy.count(c) <= code_copy.count(c)
    				   		guess_copy.count(c).times do 
    				   			hints << 'o'
    				   		end
    				   	else
    						code_copy.count(c).times do 
    							hints << 'o'
    						end
    					end
    			end
    		end
    		#ensure 'hints' is length 4 for display purposes
    		(4 - hints.length).times do 
    			hints << false
    		end

    		return hints
    	end

  end

  class Game

    include Tools

    def create_rows()
      rows = []
      12.times do 
        rows << [false, false, false, false]
      end
      return rows
    end

    attr_accessor :hints
    attr_reader :game_over
    attr_reader :cracked
    attr_reader :rows
    attr_reader :turns_left
    attr_reader :secret_code
    attr_reader :colors

    def initialize
      @rows = create_rows
      @hints = create_rows
      @secret_code = generate_code
      @turns_left = 12
      @colors = ['R', 'O', 'Y', 'G', 'B', 'V']
      @game_over = false
      @cracked = false
    end

    def code_guessed?(guess)
      if guess == @secret_code
        @cracked = true
        @game_over = true
        return true
      end
      return false
    end

    def add_hints(guess)
      current_hints = generate_hints(guess, @secret_code, @colors)
      @hints[(turns_left-1)] = current_hints
      code_guessed?(guess)
    end

    def add_guess(guess)
      @rows[turns_left-1] = guess
      add_hints(guess)
      @turns_left -= 1
      if @turns_left == 0
        @game_over = true
      end
    end
  end
end