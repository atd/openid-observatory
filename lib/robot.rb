require 'open-uri'
require 'hpricot'

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

    doc = open(uri) { |f| Hpricot(f) }

    uris = doc.search("//a")
    
    # Wordpress OpenID plugin
    openid_uris = uris.select{ |u|
      c = u.attributes['class']
      c.present? && c.include?('openid_link')
    }

    openids = openid_uris.map{ |e| e.attributes['href'] }

    # LiveJournal
    openids |= 
      # Select <span class="ljuser">..<img src="..openid">..<a rel="nofollow"></span>
      doc.search("span.ljuser").select{ |s|
        s.search("img").select{ |i|
          src = i.attributes['src']
          src.present? && src.include?('openid')
        }.any?
      }.map{ |s|
        # Select nofollow href
        s.search("a").select{ |a|
          rel = a.attributes['rel']
          rel.present? && rel.include?('nofollow')
        }.first.attributes['href']
      }

    openids.each do |id|
      puts "OpenID found: #{ id } "
      Uri.find_or_create_by_uri(id)
    end


    (uris - openid_uris).map{ |u| u.attributes['href'] }.each do |u|
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
