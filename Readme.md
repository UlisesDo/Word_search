# Word Search in Ruby

Ruby script that generates a N x N grid, where N can be any number, and randomly populates the grid with letters (A-Z).
It takes a dictionary file as argument and it finds all:

* Horizontal words from left to right in your grid
* Horizontal words from right to left in your grid
* Vertical words from top to bottom in your grid
* Vertical words from bottom to top in your grid
* Diagonal words from left to right in your grid
* Diagonal words from right to left in your grid

The script should be called like this: ruby word_search.rb dict.txt N
