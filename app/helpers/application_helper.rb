# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def graphs(options = {})
    @graph_options = options

    @default_graph_options = {
      :append => "&chma=30,30,30,90",
      :size => ( brief? ? '548x260' : '548x230' ),
      :new_markers => "N,000000,0,-1,11",
      :chart_color => "fefefe"
    }

    @graphs ||= build_graphs
  end

  def build_graphs
    [
      {
        :title   => t = 'Deployed OpenID Protocol Versions',
        :description => ( brief? ?
          "OpenID protocol versions currently deployed and announced by identifiers" :
          'OpenID protocol currently defines three versions. <a href="http://openid.net/specs/openid-authentication-1_1.html">Version 1.1</a> was published on May 2006. <a href="http://openid.net/specs/openid-authentication-2_0.html">Version 2.0</a> just a year and half later. Most of sites does not support the lastest version of the protocol. Among sites supporting it, most of them maintain compatibility with former versions.' ),
        :results => r = {
          "v1, v1.1"     => Uri.openid_version(:only_1).count,
          "v2"           => Uri.openid_version(:only_2).count,
          "all" => Uri.openid_version(:both).count
        },

        :image => pie(:title => t,
                      :data => r.values,
                      :legend => r.keys),
        :details => r.inject("") do |d, r|
          d << "<p>"
          d << "<strong>#{ r.first }</strong>: #{ r.last * 100.0 / Uri.openid_version(:any).count }"
          d << "</p>"
          d
        end
      },
      {
        :title => t = 'OpenID Discovery Technologies (%)',
        :description => ( brief? ? 
          'OpenID can be discovered both by a HTML header link or using Yadis discovery' :
          'OpenID specifications define two ways for discovering the service upon the identifier and start protocol requests. Through the specifications prioritize <a href="http://en.wikipedia.org/wiki/Yadis">Yadis</a> as the first path to be followed, it is only supported by half of the identifiers. On the other hand, <a href="http://en.wikipedia.org/wiki/HTML">HTML</a> discovery is supported by almost all the identifiers.' ),
        :results => r = {
          "HTML" => Uri.html_discovery(:any).count * 100.0 / Uri.count,
          "Yadis" => Uri.xrds_discovery(:any).count * 100.0 / Uri.count
        },

        :image => bar(:title => t,
                      :data => r.values,
                      :axis_with_labels => "x,y",
                      :axis_labels => [ r.keys, (0..4).map{ |n| n * 25 } ],
                      :max_value => 100,
                      :encoding => 'extended',
                      :bar_width_and_spacing => { :width => 50, :spacing => 30 }),
        :details => r.inject("") do |d, r|
          d << "<p>"
          d << "<strong>#{ r.first }</strong>: #{ r.last }%"
          d << "</p>"
          d
        end
      },
      {
        :title => t = "OpenID Protocol Versions in HTML discovery",
        :description => ( brief? ? 
           'Distribution of OpenID versions announced by HTML' :
           'Former versions of OpenID protocol are far more popular in identifiers providing HTML discovery.' ),
        :results => r = {
          "v1, v1.1" => Uri.html_discovery(:only_1).count,
          "v2"       => Uri.html_discovery(:only_2).count,
          "all"      => Uri.html_discovery(:both).count
        },
        :image => pie(:title => t,
                      :data => r.values,
                      :legend => r.keys),
        :details => r.inject("") do |d, r|
          d << "<p>"
          d << "<strong>#{ r.first }</strong>: #{ r.last * 100.0 / Uri.html_discovery(:any).count }%"
          d << "</p>"
          d
        end
      },
      {
        :title => t = "OpenID Protocol Versions in Yadis discovery",
        :description => ( brief? ?
          'Distribution of OpenID versions announced by Yadis' :
          'Support for OpenID 2.0 is much more frequent in Yadis discovery. More than 75% of the identifiers supports it besides former protocol versions.' ),
        :results => r = {
          "v1, v1.1" => Uri.xrds_discovery(:only_1).count,
          "v2"       => Uri.xrds_discovery(:only_2).count,
          "all"      => Uri.xrds_discovery(:both).count
        },
        :image => pie(:title => t,
                      :data => r.values,
                      :legend => r.keys),
        :details => r.inject("") do |d, r|
          d << "<p>"
          d << "<strong>#{ r.first }</strong>: #{ r.last * 100.0 / Uri.xrds_discovery(:any).count }%"
          d << "</p>"
          d
        end
      },
      {
        :title => t = 'Web Standards (%)',
        :description => ( brief? ? 
          'Main web standards found in OpenID\'s HTML' :
          'Among the Web standards found in the HTML of OpenID identifiers, <a href="http://microformats.org/">Microformats</a> is the most common. The second format most used is <a href="http://en.wikipedia.org/wiki/RSS">RSS</a>. Other popular standard is <a href="http://en.wikipedia.org/wiki/Really_Simple_Discovery">RSD</a>. <a href="http://en.wikipedia.org/wiki/Atom_%28standard%29">Atom Syndication</a> format is less used. Finally, <a href="http://www.foaf-project.org/">FOAF</a> is the least common of the Web standads analyzed.' ),
        :results => r = {
          "FOAF" => Uri.foaf(true).count * 100.0 / Uri.count,
          "Atom" => Uri.atom(true).count * 100.0 / Uri.count,
          "RSS" => Uri.rss(true).count * 100.0 / Uri.count,
          "RSD" => Uri.rsd(true).count * 100.0 / Uri.count,
          "Microformats" => Uri.microformats("_").count * 100.0 / Uri.count,
          "AtomPub" => Uri.atompub(true).count * 100.0 / Uri.count,
          "XRDS" => Uri.xrds_service_type("http").count * 100.0 / Uri.count
        }.sort{ |a, b| b.last <=> a.last },
        :image => bar(:title => t,
                      :data => r.map(&:last),
                      :axis_with_labels => "x,y",
                      :axis_labels => [ r.map(&:first), (0..4).map{ |n| n * 25 } ],
                      :max_value => 100,
                      :encoding => 'extended',
                      :bar_width_and_spacing => { :width => 50, :spacing => 23 } ),
        :details => { 'foaf' => 'FOAF',
                      'rss'  => 'RSS',
                      'atom' => 'Atom',
                      'atompub' => 'AtomPub Service Document',
                      'rsd'  => 'Really Simple Discovery (RSD)'
                    }.inject(""){ |d, s|
          d << "<p>"
          d << "<strong>#{ s.last }</strong>"
          d << "Yes #{ '%0.2f' % (Uri.send(s.first, true).count * 100.0 / Uri.count) }%"
          d << "No #{ '%0.2f' % (Uri.send(s.first, false).count * 100.0 / Uri.count) }%"
          d << "N/A #{ '%0.2f' % (Uri.send(s.first, nil).count * 100.0 / Uri.count) }%"
          d << "</p>"
          d
        } + <<-EOS
        <p>
          <strong>eXtensible Resource Descriptor Sequence (XRDS)</strong>
          Yes #{ "%0.2f" % (Uri.xrds_service_type("http").count * 100.0 / Uri.count) }%
          No #{ "%0.2f" % (Uri.xrds_service_type("[]").count * 100.0 / Uri.count) }%
        </p>

        <p>
          <strong>Microformats</strong>
          Yes #{ "%0.2f" % (Uri.microformats("_").count * 100.0 / Uri.count) }%
          No #{ "%0.2f" % (Uri.microformats("").count * 100.0 / Uri.count) }%
          N/A #{ "%0.2f" % (Uri.microformats(nil).count * 100.0 / Uri.count) }%
        </p>

        EOS
          
      },
      {
        :title => t = 'Microformats (%)',
        :description => ( brief? ?
          'Microformat types found in OpenID\'s HTML' :
          'This graph shows the most frequent <a href="http://microformats.org/">Microformats</a> found in the HTML of OpenID identifiers. <a href="http://microformats.org/wiki/rel-tag">RelTag</a> is the most popular. <a href="http://microformats.org/wiki/hcard">hCard</a> follows, something foreseeable as it is the format for personal data. XFN and Adr are also common, related with contacts and address respectively.' ),
        :results => r = UriProperty.microformats.inject({}){ |hash, m| 
                          hash[m] = (Uri.microformats(m).count * 100.0 / Uri.count)
                          hash
                        }.sort{ |a, b| b.last <=> a.last },
        :image => bar(:title => t,
                      :data => r.map(&:last),
                      :axis_with_labels => "x,y",
                      :axis_labels => [ r.map(&:first), (0..4).map{ |n| n * 25 } ],
                      :max_value => 100,
                      :encoding => 'extended',
                      :bar_width_and_spacing => { :width => 40, :spacing => 20 } ),
        :details => r.inject("") do |d, r|
          d << "<p>"
          d << "<strong>#{ r.first }</strong>: #{ r.last }%"
          d << "</p>"
          d
        end
      },
      {
        :title => t = "XRDS service types (%)",
        :description => ( brief? ?
          'Most common service types announced in XRDS files' :
          'This graph shows the most common service types announced in XRDS files. OpenID protocol uses this technology as a way to discover OpenID servers and extensions.' ),
        :results => r = xrds_results,
        :image => bar(:title => t,
                      :data => r.last.map(&:last),
                      :axis_with_labels => "x,y",
                      :axis_labels => [ [0, 100], r.last.map(&:first).reverse ],
                      :max_value => 100,
                      :size => (brief? ? nil : "548x#{ r.last.count * 25 + 70 }"),
                      :encoding => 'extended',
                      :orientation => 'h'),
        :details =>  r.first.inject("") do |d, r|
          d << "<p>"
          d << "<strong>#{ r.first }</strong>: #{ r.last }"
          d << "</p>"
          d
        end

      },
      {
        :title => t = 'OpenID URI Domains (%)',
        :description => 'Most common domains used in OpenID URIs',
        :results => r = domain_results,
        :image => bar(:title => t,
                      :data => r.last.map(&:last).flatten,
                      :axis_with_labels => "x,y",
                      :axis_labels => [ [0, 100 ], r.last.map(&:first).flatten.reverse ],
                      :max_value => 100,
                      :size => (brief? ? nil : "548x#{ r.last.count * 25 + 70 }"),
                      :encoding => 'extended',
                      :orientation => 'h'),
      },

      { :title => t = 'OpenID Providers (%)',
        :description => "Most common providers used by OpenID URIs",
        :results => r = provider_results,
        :image => bar(:title => t,
                      :data => r.last.map(&:last).flatten,
                      :axis_with_labels => "x,y",
                      :axis_labels => [ [0, 100 ], r.last.map(&:first).flatten.reverse ],
                      :max_value => 100,
                      :size => (brief? ? nil : "548x#{ r.last.count * 25 + 70 }"),
                      :encoding => 'extended',
                      :orientation => 'h'),
        :details =>  r.last.inject("") do |d, r|
          d << "<p>"
          d << "<strong>#{ r.first }</strong>: #{ r.last }"
          d << "</p>"
          d
        end
      }

    ]
  end

  %w( pie bar).each do |m|
    eval <<-EOM
      def #{ m }(options)
        options.delete_if{ |k, v| v.nil? }
        op = @default_graph_options.merge(options).merge(@graph_options)
        ap = op.delete(:append)
        op.delete(:brief)
        Gchart.#{ m }(op) + ap.to_s
      end
    EOM
  end

  def brief?
    @graph_options[:brief]
  end

  def xrds_results(n = 5)
    total = Uri.xrds_service_type('http').count

    r = UriProperty.xrds_service_types.inject({}){ |r, x|
          key = UriProperty::XrdsServiceTypes[x] || x
          r[key] = Uri.xrds_service_type(x).count
          r
        }

    sorted_r = r.sort{ |a, b| a.last <=> b.last }

    sorted_r = ( brief? ?
                 sorted_r.last(n) :
                 sorted_r.select{ |a| a.last > total * 0.01 } )
   
    sorted_r = sorted_r.map{ |a| [ a.first, a.last * 100.0 / total ] }.reverse

    [ r, sorted_r ]
  end

  def domain_results
    n = (brief? ? 5 : 7 )
    total = Uri.count

    r = Uri::Domains.inject({}){ |r, p|
          r[p] = Uri.domain(p).count
          r
        }

    r_count = r.sort{ |a, b| a.last <=> b.last }

    r_count = ( brief? ?
                r_count.last(5) :
                r_count.select{ |i| i.last > total * 0.01 } )

    r = r_count.inject({}){ |h, i| h[i.first] = i.last * 100.0 / total; h }
    r["other"] = ( total - r_count.inject(0){ |sum, i| sum + i.last } ) * 100.0 / total
    
    [ r, r.sort{ |a, b| b.last <=> a.last } ]
  end

  def provider_results
    total = Uri.count

    r = UriProperty.openid_providers.inject({}) do |r, p|
          r[p] = Uri.openid_provider(p).count
          r
        end

    r_count = r.sort{ |a, b| a.last <=> b.last }

    r_count = ( brief? ?
                r_count.last(5) :
                r_count.select{ |i| i.last > total * 0.01 } )

    r = r_count.inject({}){ |h, i| h[i.first] = i.last * 100.0 / total; h }
    r["other"] = ( total - r_count.inject(0){ |sum, i| sum + i.last } ) * 100.0 / total
    [ r, r.sort{ |a, b| b.last <=> a.last } ]
  end
end
