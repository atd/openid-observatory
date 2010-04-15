require_dependency "#{ RAILS_ROOT }/vendor/plugins/station/lib/station/html"

class Station::Html
  def openid_server_links?
    head_links.select{ |l|
      l['rel'].try(:match, /openid.server/i)
    }.any?
  end

  def openid2_provider_links?
    head_links.select{ |l|
      l['rel'].try(:match, /openid2.provider/i)
    }.any?
  end
end
