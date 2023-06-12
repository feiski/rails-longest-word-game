# frozen_string_literal: true

# The GamesController class handles the logic for a word game.

# Require necessary libraries for JSON parsing and making HTTP requests
require 'json'
require 'net/http'

class GamesController < ApplicationController
  def new
    # Generate a random set of letters for the game
    @letters = ('A'..'Z').to_a.sample(10).join(' ')
  end

  def score
    # Retrieve the submitted word and letters from the form parameters
    @word = params[:word]
    @letters = params[:letters]

    # Check if the submitted word is valid and present in the given set of letters
    if valid_word?(@word) && word_in_grid?(@word, @letters)
      # If the word is valid and present, set the session score to the length of the word
      session[:score] = @word.length
      # Initialize cumulative score in the session if it doesn't exist yet
      session[:cumulative_score] ||= 0
      # Add the session score to the cumulative score
      session[:cumulative_score] += session[:score]
      @valid_word = true # Flag to indicate a valid word
    else
      # If the word is not valid or not present, set the session score to 0
      session[:score] = 0
      @valid_word = false # Flag to indicate an invalid word
    end
  end

  private

  def valid_word?(word)
    # Construct the URL for the dictionary API
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    uri = URI(url)
    # Make an HTTP request to the API and retrieve the response
    response = Net::HTTP.get(uri)
    # Parse the JSON response into a Ruby hash
    result = JSON.parse(response)
    # Check if the 'found' key in the response is true, indicating a valid word
    result['found']
  end

  def word_in_grid?(word, letters)
    # Check if each letter of the word is present in the given set of letters
    word.upcase.chars.all? { |letter| word.upcase.count(letter) <= letters.count(letter) }
  end
end
