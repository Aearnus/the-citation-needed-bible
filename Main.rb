#!/usr/bin/env ruby

require_relative "BibleTwitter.rb"
require "pp"

if __FILE__ == $0
    puts "Beginning query thread, every 600 seconds..."
    Thread.new do
        loop do
            puts "Updating database..."
            bibleTwitter = BibleTwitter.new()
            puts "Recieved application auth..."
            bibleTwitter.updateDatabase()
            sleep 600
        end
    end
    puts "Beginning server..."
    puts `./site/Host.rb`
end
