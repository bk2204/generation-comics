ENV['RACK_ENV'] = 'test'
ENV['COMICS_DATA_FILE'] = 'doc/example/config.json'

require 'rspec'
require 'rack/test'
require 'nokogiri'

if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start 'rails'
end

def namespaces
  {
    'a'   => 'http://www.w3.org/2005/Atom',
    'dc'  => 'http://purl.org/dc/elements/1.1',
    'r1'  => 'http://purl.org/rss/1.0/',
    'rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
  }
end

RSpec::Matchers.define :have_xpath do |path, *args|
  match do |doc|
    doc = Nokogiri::XML(doc) if doc.is_a? String
    res = doc.xpath(path, namespaces.merge(doc.root.namespaces))
    if args.empty?
      !res.empty?
    else
      res.length == args[0]
    end
  end
end

RSpec::Matchers.define :be_well_formed do
  match do |doc|
    begin
      Nokogiri::XML(doc, &:strict)
      true
    rescue
      false
    end
  end
end

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end
