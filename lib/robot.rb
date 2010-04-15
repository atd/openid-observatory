require 'open-uri'
require 'nokogiri'

class Robot
  def initialize(base)
    http = 'http://'
    base = http + base unless base =~ /^#{ http }/

    @base = URI.parse(base)
    @visited_uris = Array.new

    parse(@base)
  end

  def parse(uri)
    puts "Parsing: #{ uri }"
    @visited_uris << uri

    begin
      doc = Nokogiri::HTML(open(uri))
    rescue
      return
    end

    uris = doc.xpath("//a")
    
    # Wordpress OpenID plugin
    openids =
      # Select <a class="openid_link">
      uris.select{ |u|
        c = u.attributes['class']
        c.present? && c.value.include?('openid_link')
      }.map{ |e|
        e.attributes['href'].try(:value)
      }

    # LiveJournal
    openids |= 
      # Select <span class="ljuser">..<img src="..openid">..<a rel="nofollow"></span>
      doc.css("span.ljuser").select{ |s|
        s.xpath("//img").select{ |i|
          src = i.attributes['src']
          src.present? && src.value.include?('openid')
        }.any?
      }.map{ |s|
        # Select nofollow href
        s.xpath("//a").select{ |a|
          rel = a.attributes['rel']
          rel.present? && rel.value.include?('nofollow')
        }.first.attributes['href'].try(:value)
      }

    # Save found OpenIDs
    openids.each do |id|
      puts "OpenID found: #{ id } "
      u = Uri.find_or_create_by_uri(id)
      next if u.new_record?
      u.refresh!
    end


    uris.map{ |u| u.attributes['href'].try(:value) }.compact.each do |u|
      begin
        u = uri + URI.parse(u)
      rescue
        puts "Bad URI: #{ u }"
        next
      end

      next if u.host != uri.host

      # Avoid fragments
      u.fragment = nil

      next if @visited_uris.include?(u)

      parse(u)
    end
  end
end
