ActionController::Routing::Routes.draw do |map|
  # Dirty patch for OpenID Observatory
  map.openid_uri_complete 'uris/openid_complete',
                          { :controller => 'uris',
                            :action => 'create',
                            :conditions => { :method => :get },
                            :open_id_complete => true }
end
