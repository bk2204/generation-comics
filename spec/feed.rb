require 'spec_helper'
require_relative '../app/run'

DEFAULT_FEED_COUNT = 5

describe 'the feed generator' do
  def app
    Sinatra::Application
  end

  it 'generates valid XML for Atom' do
    get '/comics/dilbert/atom'
    expect(last_response).to be_ok
    expect(last_response.body).to be_well_formed
  end

  it 'generates valid Atom' do
    get '/comics/dilbert/atom'
    body = last_response.body
    expect(body).to have_xpath('/a:feed')
    expect(body).to have_xpath('/a:feed/a:entry', DEFAULT_FEED_COUNT)
  end
end
