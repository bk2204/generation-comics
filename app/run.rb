$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/respond_with'

require 'comics/data'
require 'comics/version'

def comics
  data_file = ENV['COMICS_DATA_FILE']
  Comics::Configuration.new(data_file ? File.new(data_file) : nil)
end

def handle_error(e)
  status e.status
  content_type :plain
  body e.to_s
end

def without_errors
  yield
rescue Comics::ComicError => e
  handle_error(e)
rescue StandardError => e
  raise e if settings.development?
  e = Comics::ComicError.new
  handle_error(e)
end

def render_feed(comics, name)
  without_errors do
    respond_with :feed, comic: comics.comic(name)
  end
end

configure do
  mime_type :xhtml5, 'application/xhtml+xml'
  mime_type :atom, 'application/atom+xml'
  mime_type :rss10, 'application/rss+xml'
  mime_type :rdf, 'application/rdf+xml'
  mime_type :plain, 'text/plain; charset=UTF-8'
end

set :erb, content_type: :xhtml5

get '/' do
  without_errors do
    erb :index, locals: { comics: comics }
  end
end

get '/comics/:name/atom', provides: [:atom] do
  render_feed comics, params[:name]
end

get '/comics/:name/feed', provides: [:atom, :rss10, :rdf] do
  render_feed comics, params[:name]
end

get '/comics/:name/rss10', provides: [:rss10, :rdf] do
  render_feed comics, params[:name]
end
