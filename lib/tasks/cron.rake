namespace :cron do
  desc "Daily tasks"
  task :daily => [ 'history:record', 'uris:refresh' ]
end
