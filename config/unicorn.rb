worker_processes 2
timeout 30
preload_app true

app_path = File.expand_path('..', __dir__)

listen 3000
pid "#{app_path}/tmp/pids/unicorn.pid"

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
