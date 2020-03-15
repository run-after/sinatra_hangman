require "yaml"
require "sinatra"
require "sinatra/reloader" if development?

class Computer
  attr_reader :word
  def initialize
    @word = ''
  end

  def word_selection
    word_list = File.readlines "word_list.txt"
    until @word.length >= 5 && @word.length <= 12 do
      @word = word_list[rand(word_list.length)] 
    end
    @word.chomp.downcase
  end
end

class Player
  attr_reader :guess
  def initialize(size)
    @guess = Array.new(size, "_")
  end
end

class Game
  attr_reader :progress

  def initialize
    @answer = 'doggy'#Computer.new.word_selection
    @guess = Player.new(@answer.length).guess
    @progress = {'answer' => @answer, 'guess' => @guess, 'round' => 1, 
    'stick_man' => 0, 'missed' => Array.new}
  end
  
  def play
    
    round = progress['round']
    stick_man = progress['stick_man']
    missed = progress['missed']
    guess = progress['guess']
    answer = progress['answer']
    
    until stick_man == 6

      result = check_guess(letter)
      
      if result == "Correct"
        round += 1
        puts result
      elsif result == "Wrong"
        stick_man += 1
        round += 1
        puts result
      else
        puts result
      end

      game_over?

    end

  end

  def game_over?(answer, guess, stick_man)
    if answer.chars.join(' ') == guess
      "You win!"
    elsif stick_man == 6
      "You lose!"
    else
      false
    end
  end

  def check_guess(letter) 

    missed = progress['missed']
    guess = progress['guess']
    answer = progress['answer']
  
    if answer.include?(letter) && !guess.include?(letter)
      answer.chars.each_with_index do |x, index|
        if letter == x
          guess[index] = letter
        end
      end
      "Correct"
    elsif !missed.include?(letter) && !guess.include?(letter)
      missed << letter
      "Wrong"
    else
      "You already guessed that one!"
    end
  end

end

@@game = Game.new

get "/" do
  @progress = @@game.progress
  answer = @progress['answer']
  letter = params['letter']
  message = @@game.check_guess(letter) if letter != nil
  round = @progress['round']
  stick_man = @progress['missed'].size
  @progress['round'] += 1
  guess = @progress['guess'].join(' ')
  missed = @progress['missed'].join(', ')
  game_over = @@game.game_over?(answer, guess, stick_man)
  if game_over
    @@game = Game.new 
    @progress = @@game.progress
  end
  erb :index, :locals => {:missed => missed, :letter => letter, 
                          :message => message, :round => round,
                          :stick_man => stick_man, :game_over => game_over, 
                          :answer => answer, :guess => guess}
end

