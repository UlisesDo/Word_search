require "debugger"

Directions = [[1,0],[1,1],[0,1],[-1,1],[-1,0],[-1,-1],[0,-1],[1,-1]]

class DictWord
  attr_accessor :word, :place, :dir
  def initialize w
    @word = w
    @dir = 0  # This will hold the direction in the grid that you have to look at to see the word
    @place = nil  # This is a flag that says if the word is in the grid or not
  end
end

class Grid
  def initialize size
    @w = size
    @h = size
    @grid = "."*(@w*@h)  # Internally, our grid is a string of @w*@h size
    fill_with_random_chars
    # If you want to generate a particular grid of letters, call the following method:
    # fill_with_custom_chars
  end
  
 # Represents the grid in a matrix NxN format for printing 
 def represent
    # grid_array will be an array of strings that represent our grid in NxN format
    grid_array=[]
    @h.times{|r| grid_array<<@grid[r*@w,@w].split('')*' '}
    grid_array
  end
  
  #find the words in the grid
  def find_words words
    # We will work with "DictWord" objects rather than with raw strings
    @words = words.map{|w| DictWord.new(w)}
    # It tries to find every single word (as long as it's possible because of size of grid) in the grid 
    # If running on a UNIX system, we could use fork to improve the performance
    # Process.fork {
      @words.each{|dw| place dw if (dw.word != nil && dw.word.size <= @w )}
    # }
    # We return only the words that were found in the grid    
    return @words.select{|w|w.place != nil}  
  end
  
  private
  
 def fill_with_random_chars
    @grid.size.times{|i|@grid[i]=('A'..'Z').to_a[rand(26)]}
 end
 
 def fill_with_custom_chars
    # Fill the @grid string with the characters of the grid that you want to generate, in continuous string format.
    # For example, if you want your grid to be the following:
    # A B C D E 
    # F G H I J
    # K L M N O
    # P Q R S T
    # U V W X Y
    # Your @grid string would be as follows:
    @grid = "ABCDEFGHIJKLMNOPQRSTVWXY"
 end
  
  #It tries to find the word in the grid
  #It goes through all the positions in the grid as starting points, trying to find the word
  def place dw
    (@w*@h).times{|startpt|
      return if test_place(dw, startpt)
    }
  end
  
  # It tests if the word can be found in the grid starting by the startpt position - tests all 8 directions.
  def test_place dw, startpt
    8.times do |dir|
      pt = startpt
      good = true       
      dw.word.each_byte{|chr|  
        # It will be good while it gets finding the chars and there is a valid next point in that direction.
        good = (@grid[pt].ord==chr) && (pt=nextp(pt,dir))
        break unless good
      }
      # If good (word found in startpt point and with dir direction), it marks the word and returns.
      return mark_word(dw, startpt, dir) if good
      # If it did not succeed with that direction, it tries with the next one
      dir=(dir+1)%8
    end
    nil  # It returns nil if after trying with all 8 directions, it is still not good.
  end
  
  #It finds the next grid index in given direction
  def nextp pos, dir
    #It does not allow to step off the edges, so we check them out:
    if (pos<@w && (3..5).include?(dir)) or
       (pos+@w >= @grid.size && [0,1,7].include?(dir)) or
       (pos%@w == 0 && (5..7).include?(dir)) or
       (pos%@w+1 == @w && (1..4).include?(dir))
       return nil
    end
    # Remember: Directions = [[1,0],[1,1],[0,1],[-1,1],[-1,0],[-1,-1],[0,-1],[1,-1]]
    # Directions[dir][0] represents the movement in y index. Directions[dir][1] represents the movement in x index
    pos+Directions[dir][0]*@w+Directions[dir][1]
  end
  
  #Marks the word (dw) as found at index (idx) position in direction (dir)
  def mark_word dw, idx, dir
    dw.dir = get_direction_in_text dir
    dw.place = calculate_coordinate_in_grid idx
  end
  
  def calculate_coordinate_in_grid idx
    coordinate_y = idx/@w
    coordinate_x = idx%@w
    return [coordinate_x,coordinate_y]
  end
  
  def get_direction_in_text dir
    case dir
       when 0
         "vertical, from top to bottom"
       when 1
         "diagonal, bottom-right"
       when 2
         "horizontal, from left to right"
       when 3
         "diagonal, top-right" 
       when 4
         "vertical, from bottom to top"
       when 5
         "diagonal, top-left"
       when 6
         "horizontal, from right to left"
       else 
         "diagonal, bottom-left"
    end     
  end 

end

# Our program will be called like this: ruby word_search.rb dict.txt N
gridsize = ARGV[1].to_i
grid = Grid.new gridsize
words_to_find = File.open(ARGV[0],"r").read.split("\n").map{|line| line.split[0]}
found_words = grid.find_words words_to_find

puts "Our random GRID is the following:"
puts "---------------------------------"
puts grid.represent
puts "================================="
puts "The words found in our GRID are the following:"
puts "----------------------------------------------"
found_words.each do |found_word|
  puts "Word:#{found_word.word} - Position in the GRID:#{found_word.place} - Direction:#{found_word.dir}"
end
puts ""
puts "The total number of words found in #{ARGV[0]} is: #{found_words.size}"
