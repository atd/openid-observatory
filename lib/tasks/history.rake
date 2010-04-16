namespace :history do
  desc "Create a new history record"
  task :record => :environment do
    History.record
  end
end
