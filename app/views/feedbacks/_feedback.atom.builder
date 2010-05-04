entry.title(:type => "xhtml") do 
  entry.div(sanitize(feedback.title), :xmlns => "http://www.w3.org/1999/xhtml")
end

entry.summary(:type => "xhtml") do
  entry.div(sanitize(feedback.description), :xmlns => "http://www.w3.org/1999/xhtml")
end if feedback.respond_to?(:description.) && feedback.description.present?

entry.tag!("app:edited", feedback.updated_at.xmlschema)

entry.link(:rel => 'edit', :href => polymorphic_url(feedback, :format => :atom))
  
options = {}
options[:src], options[:type] = ( feedback.format ?
  [ polymorphic_url(feedback, :format => feedback.format), feedback.mime_type.to_s ] :
  [ polymorphic_url(feedback), 'text/html' ] )

entry.content(options)
