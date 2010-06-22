require 'rubygems'
require './main.rb'
# set :run, false
set :environment, :production
run Sinatra::Application
