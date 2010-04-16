namespace :cron do
  desc "Daily tasks"
  task :daily => [ 'history:record' ]
end
