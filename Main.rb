#!/usr/bin/env ruby

require_relative "BibleTwitter.rb"
require "pp"

if __FILE__ == $0
    bibleTwitter = BibleTwitter.new()
    puts "Recieved application auth..."
    puts "Beginning query thread, every 20 minutes..."
    Thread.new do
        loop do
            puts "Updating database..."
            bibleTwitter.updateDatabase()
            sleep 1200
        end
    end
    puts "Beginning server..."
    puts `cd site; ./Host.rb`
end
