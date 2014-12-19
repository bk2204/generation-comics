module Comics
  module Feed
    class Atom < Feed
      def initialize(data)
        @data = data
      end

      def render
        feed = <<-EOM
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>#{encode(@data.name)} Comic Feed</title>
  <id>#{@data.id}</id>
  <generator>#{Comics::Version.to_s}</generator>
  <updated>#{@data.first.date("%FT%TZ")}</updated>
        EOM
        @data.each do |entry|
          header = <<-EOM
          <entry>
            <title>#{encode(@data.name)} for #{entry.date("%F")}</title>
            <id>#{entry.id}</id>
            <updated>#{entry.date("%FT%TZ")}</updated>
            <content type="xhtml">
              <div xmlns="http://www.w3.org/1999/xhtml">
          EOM
          footer = <<-EOM
              </div>
            </content>
          </entry>
          EOM
          feed << header
          if entry.link_only?
            feed << %(<p>#{entry.html_message}</p>)
          else
            feed << %(<img src="#{entry.image}"/>)
          end
          feed << footer
        end
        feed << '</feed>'
      end
    end
  end
end
