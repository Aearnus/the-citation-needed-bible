#!/usr/bin/env ruby

require "sinatra"

set :bind, "0.0.0.0"
#set :port, 25565
set :public_folder, "public"

get "/" do
    erb :Bible, :locals => {db: JSON.parse(File.read("../db.json"))}
end