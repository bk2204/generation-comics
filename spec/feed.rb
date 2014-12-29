require 'spec_helper'
require_relative '../app/run'

DEFAULT_FEED_COUNT = 5
TAG_PATTERN = /\Atag:sandals@crustytoothpaste.net,2013:urn:sha256:id:[0-9a-f]{64}\z/

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

  it 'generates valid IDs for Atom' do
    get '/comics/dilbert/atom'
    body = Nokogiri::XML(last_response.body)
    expect(body).to have_xpath('/a:feed/a:id', 1)
    expect(body).to have_xpath('/a:feed/a:entry/a:id', DEFAULT_FEED_COUNT)

    main_id = body.xpath('/a:feed/a:id/text()', namespaces)
    entry_ids = body.xpath('/a:feed/a:entry/a:id/text()', namespaces)
    all_ids = [main_id, *entry_ids]

    expect(main_id.to_s).to match TAG_PATTERN
    entry_ids.each { |e| expect(e.to_s).to match TAG_PATTERN }

    # Verify that each ID is unique.
    expect(all_ids.map(&:to_s).uniq.length).to eq(DEFAULT_FEED_COUNT + 1)
  end
end
