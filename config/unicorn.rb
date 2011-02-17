worker_processes 2
working_directory "/Users/scott/source/diggr"
listen 8082 , :tcp_nopush => true
timeout 30
pid "/Users/scott/source/diggr/public/diggr.pid"
stderr_path "/Users/scott/source/diggr/log/unicorn.stderr.log"
stdout_path "/Users/scott/source/diggr/log/unicorn.stdout.log"
preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server,worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server,worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end