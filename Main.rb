#!/usr/bin/env ruby

require_relative "BibleTwitter.rb"
require "pp"

if __FILE__ == $0
    bibleTwitter = BibleTwitter.new()
    pp BibleTwitter::filterSearch(bibleTwitter.performSearch())
end
