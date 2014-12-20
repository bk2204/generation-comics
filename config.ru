require 'rubygems'
require 'sinatra'
require File.expand_path '../app/run.rb', __FILE__

set :environment, ENV['RACK_ENV'].to_sym
disable :run, :reload

run Sinatra::Application
