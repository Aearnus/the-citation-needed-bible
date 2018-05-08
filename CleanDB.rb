#!/usr/bin/env ruby

require_relative "BibleTwitter.rb"
require "pp"

if __FILE__ == $0
    puts "Opening database..."
    db = JSON.parse(File.read("db.json"))
    puts "Sorting..."
    db = sort_child_hash_by_key(db)
    db = db.map do |bookName, book|
        {bookName => sort_child_hash_by_key(book)}
    end.reduce do |left, right| 
        left.merge(right) 
    end
    puts "Cleaning book names and merging..."
    newDb = {}
    db.each do |bookName, book|
        newDb[BibleTwitter::cleanBookName(bookName)] = book
    end
    puts "Old DB contained #{db.keys.length} books, merged down to #{newDb.keys.length} books."
    puts "Writing database..."
    File.open("db.json", "w") do |f|
        f.write(JSON.generate(newDb))
    end
end
