require 'cgi'

module Comics
  module Feed
    class Feed
      def encode(string)
        CGI.escapeHTML(string)
      end
    end
  end
end

require 'comics/feed/atom'
