require 'digest'
require 'json'

module Comics
  class ComicError < StandardError
    def status
      500
    end

    def to_s
      'Something bad happened.'
    end
  end

  class NotFoundError < ComicError
    def status
      404
    end

    def to_s
      "That item wasn't found."
    end
  end

  class IDGenerator
    def self.generate(prefix, *args)
      hash = Digest::SHA2.new(256)
      [prefix, *args].each { |v| s = v.to_s; hash << "%d %s" % [s.length, s] }
      "tag:sandals@crustytoothpaste.net,2013:urn:sha256:id:" + hash.hexdigest
    end
  end

  class Entry
    attr_reader :id, :image, :link

    def initialize(id, date, website, image=nil)
      @id = id
      @date = date
      @link = @date.strftime(website)
      @image = @date.strftime(image) if image
    end

    def date(format=nil)
      return @date if format.nil?
      @date.strftime(format)
    end

    def link_only?
      @image.nil?
    end

    def html_message
      %(<a href="#{@link}">Click here to view the comic.</a>)
    end
  end

  class Comic
    include Enumerable

    attr_reader :tag

    def initialize(config, tag, data, defaults)
      @config = config
      @tag = tag
      @data = data
      @defaults = defaults

      now = Time.new.gmtime
      @today = Time.utc(now.year, now.month, now.day)
    end

    def name
      @data['name'] || 'Mystery Comic'
    end

    def each(&block)
      res = []
      count.times do |i|
        date = @today - (86400 * i)
        id = id_for :entry, date
        res << Entry.new(id, date, @data['comics']['daily']['link'])
      end
      if block_given?
        res.each { |e| yield e }
      else
        res
      end
    end

    def id
      id_for :comic, @today
    end

    private
    def count
      5
    end

    def id_for(type, date)
      IDGenerator.generate(@config.tag_prefix, type, @tag, date.strftime('%F'))
    end
  end

  class Configuration
    include Enumerable

    def initialize(source=nil)
      source = File.new('config.json') if source.nil?
      @data = JSON.load(source)
    end

    def each(&block)
      @data['comics'].each do |tag, data|
        yield Comic.new self, tag, data, @data["config"]["default"]
      end
    end

    def comic(tag)
      data = @data['comics'][tag]
      fail NotFoundError, "I don't know about that comic." unless data
      Comic.new self, tag, data, @data["config"]["default"]
    end

    def tag_prefix
      @data['config']['id']
    end

    def css_url
      @data['config']['css']
    end
  end
end
