require '/usr/lib/ruby/1.8/uri'

if defined?(ActiveRecord::Resource)
  require_dependency "#{ RAILS_ROOT }/vendor/plugins/station/app/models/uri"

  class Uri
    Microformats = ["Adr", "HCard", "XFN", "RelLicense", "RelTag", "XOXO", "Geo", "VoteLinks"]

    has_one :uri_property, :dependent => :destroy

    %w( foaf rss atom atompub rsd ).each do |p|
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

    named_scope :xrds_service_type, lambda { |m|
      { :joins => :uri_property,
        :conditions => [ "uri_properties.xrds_service_types LIKE ?", "%#{ m }%" ]
      }
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
  end
end
