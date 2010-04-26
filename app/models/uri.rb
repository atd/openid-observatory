require '/usr/lib/ruby/1.8/uri'

if defined?(ActiveRecord::Resource)
  require_dependency "#{ RAILS_ROOT }/vendor/plugins/station/app/models/uri"

  class Uri
    WebStandards = %w( foaf rss atom atompub rsd )
    Domains = [ "myopenid.com", "pip.verisignlabs.com", "google.com", "aol.com", "wordpress.com", "livejournal.com", "claimid.com", "yahoo.com", "blogspot.com", "myspace.com" ]

    has_one :uri_property, :dependent => :destroy

    named_scope :domain, lambda { |d|
      { :conditions => [ "uri LIKE ?", "%#{ d }%" ] }
    }

    named_scope :openid_provider, lambda { |p|
      { :conditions => [ "uri_properties.openid_providers LIKE ?", "%#{ p }%" ],
        :joins => :uri_property }
    }


    WebStandards .each do |p|
      eval <<-EOS
        named_scope :#{ p }, lambda { |#{ p }|
          { :joins => :uri_property,
            :conditions => { 'uri_properties.#{ p }' => #{ p } }
          }
        }
      EOS
    end

    named_scope :microformats, lambda { |m|
      conditions = case m
                   when NilClass
                     { "uri_properties.microformats" => nil }
                   when String
                     m.blank? ?
                       { "uri_properties.microformats" => "" } :
                       [ "uri_properties.microformats LIKE ?", "%#{ m }%" ]
                   else
                     raise "Undefined microformats scope"
                   end

      { :joins => :uri_property,
        :conditions => conditions
      }
    }

    named_scope :html_discovery, lambda { |c|
      conditions = case c
                   when :both
                     { "uri_properties.link_openid_server" => true,
                       "uri_properties.link_openid2_provider" => true }
                   when :only_1
                     { "uri_properties.link_openid_server" => true,
                       "uri_properties.link_openid2_provider" => false }
                   when :only_2
                     { "uri_properties.link_openid_server" => false,
                       "uri_properties.link_openid2_provider" => true }
                   when 1
                     { "uri_properties.link_openid_server" => true }
                   when 2
                     { "uri_properties.link_openid2_provider" => true }
                   when :any
                     [ "uri_properties.link_openid_server = ? OR uri_properties.link_openid2_provider = ?", true, true ]
                   else
                     raise "Unknown option for links_openid scope"
                   end

      { :joins => :uri_property,
        :conditions => conditions }
    }

    named_scope :xrds_service_type, lambda { |m|
      { :joins => :uri_property,
        :conditions => [ "uri_properties.xrds_service_types LIKE ?", "%#{ m }%" ]
      }
    }

    named_scope :xrds_discovery, lambda { |c|

      # FIXME: DRY!
      conditions = case c
                   when :both
                     [ "( uri_properties.xrds_service_types LIKE ? OR uri_properties.xrds_service_types LIKE ? ) AND uri_properties.xrds_service_types LIKE ?", "%#{ UriProperty::XrdsOpenIdUris[:v1_0] }%", "%#{ UriProperty::XrdsOpenIdUris[:v1_1] }%", "%#{ UriProperty::XrdsOpenIdUris[:v2_0] }%" ]
                   when :only_1
                     [ "( uri_properties.xrds_service_types LIKE ? OR uri_properties.xrds_service_types LIKE ? ) AND uri_properties.xrds_service_types NOT LIKE ?", "%#{ UriProperty::XrdsOpenIdUris[:v1_0] }%", "%#{ UriProperty::XrdsOpenIdUris[:v1_1] }%", "%#{ UriProperty::XrdsOpenIdUris[:v2_0] }%" ]
                   when :only_2
                     [ "uri_properties.xrds_service_types NOT LIKE ? AND uri_properties.xrds_service_types NOT LIKE ? AND uri_properties.xrds_service_types LIKE ?", "%#{ UriProperty::XrdsOpenIdUris[:v1_0] }%", "%#{ UriProperty::XrdsOpenIdUris[:v1_1] }%", "%#{ UriProperty::XrdsOpenIdUris[:v2_0] }%" ]
                   when 1
                     [ "uri_properties.xrds_service_types LIKE ? OR uri_properties.xrds_service_types LIKE ?", "%#{ UriProperty::XrdsOpenIdUris[:v1_0] }%", "%#{ UriProperty::XrdsOpenIdUris[:v1_1] }%" ]
                   when 2
                     [ "uri_properties.xrds_service_types LIKE ?", "%#{ UriProperty::XrdsOpenIdUris[:v2_0] }%" ]
                   when :any
                     [ "uri_properties.xrds_service_types LIKE ? OR uri_properties.xrds_service_types LIKE ? OR uri_properties.xrds_service_types LIKE ?", "%#{ UriProperty::XrdsOpenIdUris[:v1_0] }%", "%#{ UriProperty::XrdsOpenIdUris[:v1_1] }%", "%#{ UriProperty::XrdsOpenIdUris[:v2_0] }%" ]
                   else
                     raise "Unknown option for links_openid scope: #{ c }"
                   end

      { :joins => :uri_property,
        :conditions => conditions }
    }

    named_scope :openid_version, lambda { |version|
      conditions = case version
                   when :both
                     [ "( uri_properties.link_openid_server = ? AND uri_properties.link_openid2_provider = ? ) OR (( uri_properties.xrds_service_types LIKE ? OR uri_properties.xrds_service_types LIKE ? ) AND uri_properties.xrds_service_types LIKE ? )", true, true, "%#{ UriProperty::XrdsOpenIdUris[:v1_0] }%", "%#{ UriProperty::XrdsOpenIdUris[:v1_1] }%", "%#{ UriProperty::XrdsOpenIdUris[:v2_0] }%" ]
                   when :only_1
                     [ "( uri_properties.link_openid_server = ? OR uri_properties.xrds_service_types LIKE ? OR uri_properties.xrds_service_types LIKE ? ) AND uri_properties.link_openid2_provider = ? AND uri_properties.xrds_service_types NOT LIKE ?", true, "%#{ UriProperty::XrdsOpenIdUris[:v1_0] }%", "%#{ UriProperty::XrdsOpenIdUris[:v1_1] }%", false, "%#{ UriProperty::XrdsOpenIdUris[:v2_0] }%" ]
                   when :only_2
                     [ "( uri_properties.link_openid2_provider = ? OR uri_properties.xrds_service_types LIKE ? ) AND uri_properties.link_openid_server = ? AND uri_properties.xrds_service_types NOT LIKE ? AND uri_properties.xrds_service_types NOT LIKE ? ", true, "%#{ UriProperty::XrdsOpenIdUris[:v2_0] }%", false, "%#{ UriProperty::XrdsOpenIdUris[:v1_0] }%", "%#{ UriProperty::XrdsOpenIdUris[:v1_1] }%" ]
                   when :any
                     [ "uri_properties.link_openid_server = ? OR uri_properties.link_openid2_provider = ? OR uri_properties.xrds_service_types LIKE ? OR uri_properties.xrds_service_types LIKE ? OR uri_properties.xrds_service_types LIKE ?", true, true, "%#{ UriProperty::XrdsOpenIdUris[:v1_0] }%", "%#{ UriProperty::XrdsOpenIdUris[:v1_1] }%", "%#{ UriProperty::XrdsOpenIdUris[:v2_0] }%" ]
                   else
                     raise "Unknown option for openid_version scope: #{ version }"
                   end
      { :joins => :uri_property,
        :conditions => conditions }
    }



    # Rails Station REST magic
    acts_as_resource

    def refresh!
      uri_property.foaf = foaf?
      uri_property.rss = html.rss_links.any?
      uri_property.atom = html.atom_links.any?
      uri_property.atompub = html.atom_service_links.any?
      uri_property.rsd = html.rsd_links.any?
      uri_property.microformats = html.microformats.map{ |m| m.class.to_s.demodulize }.join(",")
      uri_property.xrds_service_types = xrds_service_types
      uri_property.link_openid_server = html.openid_server_links?
      uri_property.link_openid2_provider = html.openid2_provider_links?
      uri_property.openid_providers = openid_providers
      uri_property.save!
    end


    # Do OpenID discover and update uri to OpenID claimed ID
    before_validation_on_create do |uri|
      uri.openid? && uri.to_openid
      true
    end

    validates_uniqueness_of :uri

    def validate_on_create
      if ! openid?
        errors.add(:uri, "OpenID discovery failed")
      elsif uri =~ /^=/
        # If you know how to manage them, feel free to send a patch!
        errors.add(:uri, "Sorry, only http uris are supported")
      end
    end

    after_create :create_uri_property

    def openid_providers
      ( openid_discover.last.map{ |s| s.server_url } |
        html.openid_providers ).flatten.compact.uniq
    end
  end
end
