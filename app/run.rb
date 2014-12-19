$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'sinatra'

require 'comics/data'
require 'comics/feed'
require 'comics/version'

comics = Comics::Configuration.new

configure do
  mime_type :atom, 'application/atom+xml'
end

get '/' do
  erb :index, locals: { comics: comics }
end

get '/comics/:name/atom' do
  content_type :atom
  body Comics::Feed::Atom.new(comics.comic(params['name'])).render
end

get '/comics/:name/feed' do
  content_type :atom
  body Comics::Feed::Atom.new(comics.comic(params['name'])).render
end
