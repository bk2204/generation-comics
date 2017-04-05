require 'spec_helper'

require 'comics/data'
require 'stringio'

describe Comics::Comic do
  let(:config) do
    Comics::Configuration.new(StringIO.new(<<-EOM, 'r'))
    {
      "comics":{
        "dilbert":{
          "name":"Dilbert",
          "comics":{
            "daily":{
              "website": "http://www.dilbert.com/strips/comic/",
              "link": "http://www.dilbert.com/strips/comic/%F/",
              "type":"link",
              "frequency":"daily",
              "time":"01:00"
            }
          }
        }
      },
      "config": {
        "id":"https://example.org/",
        "css":"",
        "default":{
        }
      }
    }
    EOM
  end

  it 'handles last update times properly' do
    early = Time.at(1_491_264_000).gmtime
    late = Time.at(1_491_271_200).gmtime
    parse = Time.method(:parse)
    time = class_double('Time').as_stubbed_const
    [
      [early, '2017-04-03T01:00:00'],
      # If the time hasn't happened yet, then use the previous date.
      [late,  '2017-04-04T01:00:00'],
    ].each do |(stamp, expected)|
      allow(time).to receive(:now) { stamp }
      allow(time).to receive(:parse) { |*args| parse.call(*args) }
      c = config.comic('dilbert')
      entry = c.first
      expect(entry.date('%FT%T')).to eq expected
    end
  end
end
