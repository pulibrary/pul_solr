# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :environment_variable, "SOLR_ENV"
set :job_template, "bash -l -c 'export PATH=\"/usr/local/bin/:$PATH\" && :job'"

job_type :rake, "cd :path && :environment_variable=:environment bundle exec rake :task"

every 1.day, roles: [:db] do
  rake "pul_solr:solr8:backup"
end
