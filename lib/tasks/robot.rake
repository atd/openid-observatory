namespace :robot do
  desc "Search in URI"
  task :search => :environment do
    Robot.new ENV['URI']
  end

  desc "Search in sources.yml"
  task :seed => :environment do
    YAML.load_file(File.join("#{ RAILS_ROOT }", "sources.yml")).each do |uri|
      puts "Seeding with #{ uri }"
      Robot.new uri
    end
  end
end

