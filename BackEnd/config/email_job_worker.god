rails_env   = ENV['RAILS_ENV']  || "development"
rails_root  = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/..'
num_workers = 1

num_workers.times do |num|
  God.watch do |w|
    w.dir      = "#{rails_root}"
    w.name     = "resque_email_job_#{num}"
    w.group    = 'resque_worker'
    w.interval = 30.seconds
    w.env      = {"QUEUE"=>"send_emails", "RAILS_ENV"=>rails_env}
    w.start    = "rake -f #{rails_root}/Rakefile environment resque:work"
    w.log = File.join(rails_root,"log/god.log")

    # clean pid files before start if necessary
    w.behavior(:clean_pid_file)

    # restart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 1024.megabytes
        c.times = 2
      end
    end

    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 5.seconds
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_running) do |c|
        c.running = false
      end
    end
  end
end
