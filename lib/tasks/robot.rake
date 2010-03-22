namespace :robot do
  desc "Search in URI"
  task :search => :environment do
    Robot.new ENV['URI']
  end

  desc "Search in sources.yml"
  task :seed => :environment do
    YAML.load_file(File.join("#{ RAILS_ROOT }", "sources.yml")).each do |uri|
      ENV['URI'] = uri
      puts "Seeding with #{ uri }"
      Rake::Task["robot:search"].invoke
    end
  end
end

