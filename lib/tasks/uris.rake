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
end
