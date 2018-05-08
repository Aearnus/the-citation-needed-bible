#!/usr/bin/env ruby

require_relative "Credentials.rb"
require "twitter"
require "json"

$BIBLE_BOOK_REGEX = /(\d?)\s?(\S{2,}|Acts of the \S{2,}|Song of \S{2,})\s?(\d{1,2}):(\d{1,2})/i

def sort_child_hash_by_key(hash)
    return hash.map do |key, value| 
        {key => value.sort_by{|k,v| k.to_i}.to_h} 
    end.reduce do |left, right| 
        left.merge(right) 
    end
end

class BibleTwitter
    attr_accessor :client
    
    def initialize()
        @client = Twitter::REST::Client.new do |config|
            config.consumer_key        = CONSUMER_KEY
            config.consumer_secret     = CONSUMER_SECRET
            # config.access_token        = ACCESS_TOKEN
            # config.access_token_secret = ACCESS_TOKEN_SECRET
        end
    end
    
    def performSearch()
        puts "Connecting to the Twitter API..."
        out = @client.search("bible OR quote OR jesus OR strength OR inspirational OR #bible OR #citationneededbible OR #thecitationneededbible -filter:retweets -filter:replies -filter:links", result_type: "recent", count: 100)
        puts "Completed Twitter API search, got #{out.to_a.length} tweets."
        return out
    end
    
    def self.filterTweet(tweet)
        puts "Filtering tweet #{tweet.text}..."
        tweet_matches = tweet.text.match($BIBLE_BOOK_REGEX)
        if !tweet_matches.nil?
            puts "This tweet matches the regex."
            return {
		        text: tweet_matches.string,
		        before: tweet_matches.pre_match,
                book_num: tweet_matches[1],
                book: tweet_matches[2],
                chapter: tweet_matches[3],
                verse: tweet_matches[4],
		        after: tweet_matches.post_match
            }
        end
        puts "This tweet does not match the regex."
        return nil
    end
    
    def self.filterSearch(search)
        out = []
        search.each do |tweet|
            filtered = BibleTwitter::filterTweet(tweet)
            if !filtered.nil?
                out << filtered
            end
        end
        return out
    end
    
    def self.expandAcronym(bookAcronym)
        return bookAcronym
    end
    
    def self.cleanBookName(bookName)
        #remove all non-letters or whitespace
        bookName = bookName.gsub(/[^\w\s]/, " ")
        #ensure there is exactly one space between the number and the number and the name
        bookMatch = bookName.match(/(\d?)\s*(\w+)/)
        if (bookMatch.nil?)
            puts "Found book name exception: #{bookName}"
            # most of these are empty, so for shits and giggles, we'll make it book Null
            # how these get into the DB? i have no idea and this is too dumb of a project to care
            bookName = "Null"
        else 
            if bookMatch[1].empty?
                bookName = BibleTwitter::expandAcronym(bookMatch[2])
            else
                bookName = "#{bookMatch[1]} #{BibleTwitter::expandAcronym(bookMatch[2])}"
            end
        end
        #ensure that every space is only 1 space, and capitalize every word
        bookName = bookName.split(?\ ).map(&:capitalize).join(?\ )
        return bookName
    end
    
    def updateDatabase()
        db = JSON.parse(File.read("db.json"))
        searches = BibleTwitter::filterSearch(self.performSearch())
        puts "Found #{searches.length} tweets following the search query and the regex..."
        searches.each do |search|
            verseText = if search[:before].length > search[:after].length
                            search[:before]
                        else
                            search[:after]
                        end
            bookName = if search[:book_num].empty?
                            search[:book]
                       else
                            "#{search[:book_num]} #{search[:book]}"
                       end
            chapterName = search[:chapter].to_i
            verseName = search[:verse].to_i
            if db[bookName].nil?
                db[bookName] = {}
            end
            if db[bookName][chapterName].nil?
                db[bookName][chapterName] = {}
            end
            if db[bookName][chapterName][verseName].nil?
                db[bookName][chapterName][verseName] = {}
            end
            db[bookName][chapterName][verseName] = verseText
            puts "The book #{bookName}, chapter #{chapterName} and verse #{verseName}: #{verseText}"
        end
        # recursively sort the db by key
        # ...trust me
        db = sort_child_hash_by_key(db)
        db = db.map do |bookName, book|
            {bookName => sort_child_hash_by_key(book)}
        end.reduce do |left, right| 
            left.merge(right) 
        end
        
        File.open("db.json", "w") do |f|
            f.write(JSON.generate(db))
        end
    end
end
