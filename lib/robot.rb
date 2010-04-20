require 'open-uri'
require 'nokogiri'

class Robot
  def initialize(base)
    http = 'http://'
    base = http + base unless base =~ /^#{ http }/

    @base = URI.parse(base)
    @visited_uris = Array.new
    @visited_openids = Array.new

    parse(@base)
  end

  def parse(uri)
    puts "#{ "Parsing".pur } #{ uri }"
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
    # livejournal.com
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
        }.map{ |l|
          l.attributes['href'].try(:value)
        }
      }.flatten.compact

    # StackOverflow Blog
    # http://blog.stackoverflow.com/
    openids |=
      doc.css("ol.commentlist a.url").map{ |a|
        a.attributes['href'].try(:value)
      }
      
    # Save found OpenIDs
    openids.each do |id|
      print "#{ "OpenID".dark_blue } #{ id } "

      if @visited_openids.include?(id)
        puts "repeated.".yellow
        next
      end

      @visited_openids << id

      if Uri.find_by_uri(id)
        puts "already saved.".yellow
        next
      end

      u = Uri.create(:uri => id)

      if u.new_record?
        puts "invalid.".red
        next
      end

      puts "added.".green
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
