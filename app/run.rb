$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'sinatra'

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
    e = ComicError.new
    status e.status
    content_type :plain
    body e.to_s
  end
end

configure do
  mime_type :xhtml5, 'application/xhtml+xml'
  mime_type :atom, 'application/atom+xml'
  mime_type :plain, 'text/plain; charset=UTF-8'
end

set :erb, content_type: :xhtml5

get '/' do
  without_errors do
    erb :index, locals: { comics: comics }
  end
end

get '/comics/:name/atom' do
  without_errors do
    comic = comics.comic params['name']
    erb :atom, locals: { comic: comic }, content_type: :atom
  end
end

get '/comics/:name/feed' do
  without_errors do
    comic = comics.comic params['name']
    erb :atom, locals: { comic: comic }, content_type: :atom
  end
end
