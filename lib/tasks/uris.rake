namespace :uris do
  desc "Update URIs"
  task :refresh => :environment do
    Uri.all.each do |u|
      puts "Refreshing: #{ u.to_s }"
      begin
        u.refresh!
      rescue Timeout::Error, Exception => e
        puts e.inspect
        next
      end
    end
  end

  desc "Purge URIs that are not OpenID"
  task :purge => :environment do
    Uri.all.each do |u|
      oid = u.openid?

      if oid.nil?
        puts "Not responding URI: #{ u }"
      elsif ! oid
        puts "Purging #{ u }"
        u.destroy
      end
    end
  end
end
