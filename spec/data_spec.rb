require 'spec_helper'
require_relative '../app/run'

require 'json'

describe 'the JSON data' do
  def app
    Sinatra::Application
  end

  def json
    JSON.parse(last_response.body, symbolize_names: true)
  end

  it 'generates valid JSON' do
    get '/comics/dilbert'
    expect(last_response).to be_ok
    expect{ JSON.parse(last_response.body) }.not_to raise_error
  end

  it 'generates the proper content type for JSON data' do
    get '/comics/dilbert'
    expect(last_response['Content-Type']).to match(%r{application/json})
  end

  it 'generates a 404 for nonexistent JSON data' do
    get '/comics/nonexistent'
    expect(last_response.not_found?).to be true
  end

  it 'generates a single data element' do
    get '/comics/dilbert'
    expect(json[:data]).to be_a Hash
  end

  it 'generates proper links' do
    url = '/comics/dilbert'
    get url
    expect(json[:data][:self]).to eq url
    expect(json[:data][:feeds][:*]).to eq "/comics/dilbert/feed"
    expect(json[:data][:feeds][:'application/atom+xml']).to \
           eq "/comics/dilbert/atom"
    expect(json[:data][:feeds][:'application/rdf+xml']).to \
           eq "/comics/dilbert/rss10"
  end

  it 'generates valid links' do
    get '/comics/dilbert'
    urls = json[:data][:feeds].values
    urls << json[:data][:self]
    urls.each do |u|
      get u
      expect(last_response).to be_ok
    end
  end
end
