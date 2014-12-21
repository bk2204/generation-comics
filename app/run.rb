$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'sinatra'

require 'comics/data'
require 'comics/version'

comics = Comics::Configuration.new

configure do
  mime_type :atom, 'application/atom+xml'
end

get '/' do
  erb :index, locals: { comics: comics }
end

get '/comics/:name/atom' do
  comic = comics.comic params['name']
  erb :atom, locals: { comic: comic }, content_type: :atom
end

get '/comics/:name/feed' do
  comic = comics.comic params['name']
  erb :atom, locals: { comic: comic }, content_type: :atom
end
