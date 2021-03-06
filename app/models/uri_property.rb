class UriProperty < ActiveRecord::Base
  class << self
    # Dynamic enumeration of several parameters
    def reset
      @openid_providers = @microformats = @xrds_service_types = nil
    end

    %w( openid_providers xrds_service_types ).each do |m|
      eval <<-EOM
        def #{ m }
          @#{ m } ||=
            all.map{ |u| Array(u.#{ m }) }.flatten.compact.uniq
        end
      EOM
    end

    def microformats
      @microformats ||=
        all.map{ |u| u.microformats.split(",") }.flatten.compact.uniq
    end
  end

  # Microformat abbrevations
  Microformats = {
    'DefinitionList' => 'DefList'
  }

  XrdsOpenIdUris = {
    :v1_0 => "http://openid.net/signon/1.0",
    :v1_1 => "http://openid.net/signon/1.1",
    :v2_0 => "http://specs.openid.net/auth/2.0/signon"
  }

  XrdsServiceTypes = {
    "http://openid.net/signon/1.0" => "OpenID Authentication 1.0",
    "http://openid.net/signon/1.1" => "OpenID Authentication 1.1",
    "http://openid.net/sreg/1.0"   => "OpenID Simple Registration Extension 1.0",
    "http://openid.net/srv/ax/1.0" => "OpenID Attribute Exchange 1.0",
    "http://openid.net/extensions/sreg/1.1" => "OpenID Simple Registration Extension 1.1",
    "http://specs.openid.net/auth/2.0/server" => "OpenID Authentication 2.0 OP Identifier Element",
    "http://specs.openid.net/auth/2.0/signon" => "OpenID Authentication 2.0 Claimed Identifier Element",
    "http://specs.openid.net/extensions/pape/1.0" => "OpenID Provider Authentication Policy Extension 1.0",
    "http://specs.openid.net/extensions/ui/1.0/mode/popup" => "OpenID User Interface Extension 1.0",
    "http://specs.openid.net/extensions/ui/1.0/icon" => "OpenID User Interface Extension 1.0",
    "http://specs.openid.net/extensions/oauth/1.0" => "OpenID OAuth Extension",
    "http://schemas.openid.net/pape/policies/2007/06/phishing-resistant" => "OpenID PAPE Phishing-Resistant Authentication",
    "http://schemas.openid.net/pape/policies/2007/06/multi-factor" => "OpenID PAPE Multi-Factor Authentication",
    "http://schemas.openid.net/pape/policies/2007/06/multi-factor-physical" => "OpenID PAPE Physical Multi-Factor Authentication",
    "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/privatepersonalidentifier" => "OpenID GSA Profile extension",
    "http://www.idmanagement.gov/schema/2009/05/icam/no-pii.pdf" => "OpenID GSA Profile extension",
    "http://www.idmanagement.gov/schema/2009/05/icam/openid-trust-level1.pdf" => "OpenID GSA Profile extension",
    "http://csrc.nist.gov/publications/nistpubs/800-63/SP800-63V1_0_2.pdf" => "OpenID NIST extension",
    "http://specs.openid.net/extensions/ui/1.0/lang-pref" => "OpenID Language User Interface Extension 1.0",
  }

  belongs_to :uri

  serialize :xrds_service_types, Array
  serialize :openid_providers, Array

end
