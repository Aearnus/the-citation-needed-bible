#!/usr/bin/env ruby

require_relative "Credentials.rb"
require "twitter"
require "json"

$BIBLE_BOOK_REGEX = /(.+?)(\d?)\s?(\w{2,}|Acts of the \w{2,}|Song of \w{2,})+\.?\s?(\d{1,2}):(\d{1,2})(.+)/i

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
        return @client.search("bible OR quote OR love OR jesus OR strength OR inspirational OR #bible OR #citationneededbible OR #thecitationneededbible -filter:retweets", result_type: "recent", count: 20)
    end
    
    def self.filterTweet(tweet)
        tweet_matches = tweet.text.match($BIBLE_BOOK_REGEX)
        if !tweet_matches.nil?
            return {
                text: tweet_matches[0],
                before: tweet_matches[1],
                book_num: tweet_matches[2],
                book: tweet_matches[3],
                chapter: tweet_matches[4],
                verse: tweet_matches[5],
                after: tweet_matches[6]
            }
        end
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
        File.open("db.json", "w") do |f|
            f.write(JSON.generate(db))
        end
    end
end

if __FILE__ == $0
    puts "Updating database..."
    bibleTwitter = BibleTwitter.new()
    bibleTwitter.updateDatabase()
end