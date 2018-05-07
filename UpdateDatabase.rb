require_relative "Credentials.rb"

def initTwitter()
    return Twitter::REST::Client.new do |config|
        config.consumer_key        = CONSUMER_KEY
        config.consumer_secret     = CONSUMER_SECRET
        config.access_token        = ACCESS_TOKEN
        config.access_token_secret = ACCESS_TOKEN_SECRET
    end
end