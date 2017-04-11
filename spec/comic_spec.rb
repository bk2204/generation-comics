require 'spec_helper'

require 'comics/data'
require 'stringio'

describe Comics::Comic do
  let(:main_dir) { File.expand_path(File.join(File.dirname(__FILE__), '..')) }
  let(:config) do
    Comics::Configuration.new(File.new(File.join(main_dir,
                                                 'spec/fixtures/config.json')))
  end

  it 'handles last update times properly' do
    [
      [Time.new(2017, 4, 4, 11, 0, 0, 0), '2017-04-03T12:00:00'],
      # If the time hasn't happened yet, then use the previous date.
      [Time.new(2017, 4, 4, 13, 0, 0, 0), '2017-04-04T12:00:00'],
    ].each do |(stamp, expected)|
      allow(Time).to receive(:now) { stamp }
      c = config.comic('dilbert')
      entry = c.first
      expect(entry.date('%FT%T')).to eq expected
    end
  end

  it 'produces consistent IDs for entries based on timestamp' do
    entry_pairs = []
    [
      [Time.new(2017, 4, 4, 11, 0, 0, 0),
       '0c093ce5524e932ce3d72bb67c848ed5afedf40cc929ed581d2d0cab381193c4'],
      # If the time hasn't happened yet, then use the previous date.
      [Time.new(2017, 4, 4, 13, 0, 0, 0),
       'f2a54d85608e91ca4cc029d9b90ebdda48531a749e9424a7d93f525877c0b06a'],
    ].each do |(stamp, expected)|
      allow(Time).to receive(:now) { stamp }
      c = config.comic('dilbert')
      entry = c.first
      expect(entry.id).to match(
        /\Atag:sandals@crustytoothpaste.net,2013:urn:sha256:id:([0-9a-f]{64})/
      )
      expect(entry.id).to end_with expected
      entry_pairs << c.map { |e| [e.date, e.id] }
    end
    # Verify that the entries are consistent between the items generated on two
    # different days.  Ignore the oldest and most recent entries, since those
    # will not overlap between the two days.
    expect(entry_pairs[0][0..-2]).to eq entry_pairs[1][1..-1]
  end

  it 'escapes ampersands in generated HTML properly' do
    c = config.comic('example')
    expect(c.first.html_message).to match(/&amp;/)
  end
end
