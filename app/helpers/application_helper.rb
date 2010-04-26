# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def graphs(options = {})
    @graph_options = {
      :append => "&chma=30,30,30,90",
      :size => '548x260',
      :new_markers => "N,000000,0,-1,11",
      :chart_color => "fefefe"
    }

    @graph_options.merge!(options)

    @graphs ||= build_graphs
  end

  def build_graphs
    [
      {
        :title   => t = 'Distribution of OpenID versions',
        :description => "OpenID protocol versions currently supported",
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
        :title => 'OpenID Discovery Technologies (%)',
        :description => 'OpenID service can be discovered by HTML link in header or using XRDS discovery',
        :results => r = {
          "HTML" => Uri.html_discovery(:any).count * 100.0 / Uri.count,
          "XRDS" => Uri.xrds_discovery(:any).count * 100.0 / Uri.count
        },

        :image => bar(:title => "OpenID Discovery Technologies",
                      :data => r.values,
                      :axis_with_labels => "x,y",
                      :axis_labels => [ r.keys, (0..4).map{ |n| n * 25 } ],
                      :max_value => 100,
                      :bar_width_and_spacing => { :width => 50, :spacing => 30 }),
        :details => r.inject("") do |d, r|
          d << "<p>"
          d << "<strong>#{ r.first }</strong>: #{ r.last }%"
          d << "</p>"
          d
        end
      },
      {
        :title => t = "Distribution of OpenID versions. HTML discovery",
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
        :title => t = "Distribution of OpenID versions. XRDS discovery",
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
        :details => 'Main web standards found in OpenIDs',
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
        :details => 'Microformats types found in OpenIDs',
        :results => r = UriProperty.microformats.inject({}){ |hash, m| 
                          hash[m] = (Uri.microformats(m).count * 100.0 / Uri.count)
                          hash
                        }.sort{ |a, b| b.last <=> a.last },
        :image => bar(:title => t,
                      :data => r.map(&:last),
                      :axis_with_labels => "x,y",
                      :axis_labels => [ r.map(&:first), (0..4).map{ |n| n * 25 } ],
                      :max_value => 100,
                      :bar_width_and_spacing => { :width => 40, :spacing => 20 } ),
        :details => r.inject("") do |d, r|
          d << "<p>"
          d << "<strong>#{ r.first }</strong>: #{ r.last }%"
          d << "</p>"
          d
        end
      },
      {
        :title => t = "eXtensible Resource Descriptor Sequence (XRDS)",
        :results => r = UriProperty::XrdsServiceTypes.inject({}){ |r, x|
                          r[x.last] = Uri.xrds_service_type(x.first).count
                          r
                        },
        :image => bar(:title => t,
                      :data => r.values,
                      :axis_with_labels => "x,y",
                      :axis_labels => [ r.keys, [0, Uri.xrds_service_type('http').count] ],
                      :max_value => Uri.xrds_service_type('http').count,
                      :bar_width_and_spacing => { :width => 50, :spacing => 20 }),
        :details =>  r.inject("") do |d, r|
          d << "<p>"
          d << "<strong>#{ r.first }</strong>: #{ r.last }"
          d << "</p>"
          d
        end

      },
      {
        :title => t = 'OpenID URI Domains',
        :results => r = domain_results,
        :image => bar(:title => t,
                      :data => r.last.map(&:last).flatten,
                      :axis_with_labels => "x,y",
                      :axis_labels => [ r.last.map(&:first).flatten, [0, r.first['other'] ]],
                      :bar_width_and_spacing => { :width => 50, :spacing => 30 }),
      },
      { :title => t = 'OpenID Providers',
        :results => r = provider_results,
        :image => bar(:title => t,
                      :data => r.last.map(&:last).flatten,
                      :axis_with_labels => "x,y",
                      :axis_labels => [ [0, r.first['other'] ], r.last.map(&:first).flatten.reverse ],
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
        op = @graph_options.dup
        ap = op.delete(:append)
        Gchart.#{ m }(options.merge(op)) + ap.to_s
      end
    EOM
  end

  def microformats_results

  end

  def domain_results
    r = Uri::Domains.inject({}){ |r, p|
          c = Uri.domain(p).count
          r[p] = c if c > Uri.count * 0.01
          r
        }

    r["other"] = Uri.count - r.values.inject(0){ |sum, value| sum + value }
    
    [ r, r.sort{ |a, b| b.last <=> a.last } ]
  end

  def provider_results(n = 5)
    r = UriProperty.openid_providers.inject({}) do |r, p|
          c = Uri.openid_provider(p).count
          r[p] = c if c > Uri.count * 0.01
          r
        end
    r = r.sort{ |a, b| a.last <=> b.last }.last(5).inject({}){ |h, i| h[i.first] = i.last; h }
    r["other"] = Uri.count - r.values.inject(0){ |sum, value| sum + value }
    # TODO: convert toconvert to %
    [ r, r.sort{ |a, b| b.last <=> a.last } ]
  end
end
