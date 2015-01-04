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

  it 'generates Atom feeds with an author' do
    get '/comics/dilbert/atom'
    body = last_response.body
    expect(body).to have_xpath('/a:feed/a:author')
    expect(body).to have_xpath('/a:feed/a:author/a:name')
    expect(body).to have_xpath('/a:feed/a:author/a:name/text()')
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

  it 'generates valid XML for RSS 1.0' do
    get '/comics/dilbert/rss10'
    expect(last_response).to be_ok
    expect(last_response.body).to be_well_formed
  end

  it 'generates valid RSS 1.0' do
    get '/comics/dilbert/rss10'
    body = last_response.body
    expect(body).to have_xpath('/rdf:RDF')
    expect(body).to have_xpath('/rdf:RDF/r1:channel')
    expect(body).to have_xpath('/rdf:RDF/r1:channel/r1:items/rdf:Seq/rdf:li',
                               DEFAULT_FEED_COUNT)
    expect(body).to have_xpath('/rdf:RDF/r1:item', DEFAULT_FEED_COUNT)
  end

  it 'has rdf:li elements that match item tags in RSS 1.0' do
    get '/comics/dilbert/rss10'
    body = Nokogiri::XML(last_response.body)

    items_xpath = '/rdf:RDF/r1:channel/r1:items/rdf:Seq/rdf:li/@rdf:resource'
    body.xpath(items_xpath, namespaces).map(&:to_s).each do |url|
      expect(body).to have_xpath("/rdf:RDF/r1:item[@rdf:about = '#{url}']", 1)
    end
  end

  it 'generates RSS 1.0 items with non-empty titles' do
    get '/comics/dilbert/rss10'
    body = last_response.body
    expect(body).to have_xpath('/rdf:RDF/r1:item/r1:title', DEFAULT_FEED_COUNT)
    expect(body).to have_xpath('/rdf:RDF/r1:item/r1:title[text()]',
                               DEFAULT_FEED_COUNT)
    expect(body).to have_xpath('/rdf:RDF/r1:item/r1:title[not(text() = "")]',
                               DEFAULT_FEED_COUNT)
  end

  it 'generates RSS 1.0 items with non-empty link tags' do
    get '/comics/dilbert/rss10'
    body = last_response.body
    expect(body).to have_xpath('/rdf:RDF/r1:item/r1:link', DEFAULT_FEED_COUNT)
    expect(body).to have_xpath('/rdf:RDF/r1:item/r1:link[text()]',
                               DEFAULT_FEED_COUNT)
    expect(body).to have_xpath('/rdf:RDF/r1:item/r1:link[not(text() = "")]',
                               DEFAULT_FEED_COUNT)
  end
end
