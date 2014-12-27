$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'sinatra'
require "sinatra/reloader" if development?

require 'comics/data'
require 'comics/version'

comics = Comics::Configuration.new

def without_errors
  begin
    yield
  rescue Comics::ComicError => e
    status e.status
    content_type :plain
    body e.to_s
  rescue
    e = Comics::ComicError.new
    status e.status
    content_type :plain
    body e.to_s
  end
end

def render_feed(comics, name, type)
  without_errors do
    comic = comics.comic name
    erb type, locals: { comic: comic }, content_type: type
  end
end

configure do
  mime_type :xhtml5, 'application/xhtml+xml'
  mime_type :atom, 'application/atom+xml'
  mime_type :rss10, 'application/rss+xml; version="http://purl.org/rss/1.0/"'
  mime_type :plain, 'text/plain; charset=UTF-8'
end

set :erb, content_type: :xhtml5

get '/' do
  without_errors do
    erb :index, locals: { comics: comics }
  end
end

get '/comics/:name/atom' do
  render_feed comics, params[:name], :atom
end

get '/comics/:name/feed' do
  types = { 'application/atom+xml' => :atom, 'application/rss+xml' => :rss10 }
  t = request.preferred_type(types.keys)
  render_feed comics, params[:name], types[t]
end

get '/comics/:name/rss10' do
  render_feed comics, params[:name], :rss10
end
