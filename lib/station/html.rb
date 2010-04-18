require_dependency "#{ RAILS_ROOT }/vendor/plugins/station/lib/station/html"

class Station::Html
  def openid_server_links
    head_links.select{ |l|
      l['rel'].try(:match, /openid.server/i)
    }
  end

  def openid_server_links?
    openid_server_links.any?
  end

  def openid2_provider_links
    head_links.select{ |l|
      l['rel'].try(:match, /openid2.provider/i)
    }
  end

  def openid2_provider_links?
    openid2_provider_links.any?
  end

  def openid_providers
    ( openid_server_links | openid2_provider_links ).map{ |l|
      l['href']
    }.compact
  end
end
