#!/usr/bin/env ruby

require_relative "BibleTwitter.rb"
require "pp"

if __FILE__ == $0
    puts "Updating database..."
    bibleTwitter = BibleTwitter.new()
    bibleTwitter.updateDatabase()
end
