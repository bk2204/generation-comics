require 'spec_helper'

require 'comics/data'
require 'stringio'

describe Comics::Comic do
  let(:main_dir) { File.expand_path(File.join(File.dirname(__FILE__), '..')) }
  let(:config) do
    Comics::Configuration.new(File.new(File.join(main_dir,
                                                 %w[doc/example/config.json])))
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
end
