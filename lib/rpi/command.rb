begin
  require 'daemons'
rescue LoadError
  raise "You need to add gem 'daemons' to your Gemfile if you wish to use it."
end
require 'optparse'
require 'logger'

module Rpi
  class Command
    attr_accessor :worker_count

    def initialize(args)
      @options = {
        quiet: true,
        pid_dir: "#{Rails.root}/tmp/pids",
        host: '127.0.0.1',
        port: 8787
      }

      @worker_count = 1
      @monitor = false

      opts = OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename($0)} [options] start|stop|restart|run"

        opts.on('-h', '--help', 'Show this message') do
          puts opts
          exit 1
        end
        opts.on('--host=[HOST]', 'DRb host, default 127.0.0.1.') do |host|
          @options[:host] = host
        end
        opts.on('--port=[PORT]', 'DRb posrt, default 8787.') do |port|
          @options[:port] = port
        end
        opts.on('--pid-dir=DIR', 'Specifies an alternate directory in which to store the process ids.') do |dir|
          @options[:pid_dir] = dir
        end
        opts.on('-m', '--monitor', 'Start monitor process.') do
          @monitor = true
        end
      end
      @args = opts.parse!(args)
    end

    def daemonize
      dir = @options[:pid_dir]
      Dir.mkdir(dir) unless File.exists?(dir)
      Daemons.run_proc("drb_server", :dir => dir, :dir_mode => :normal, :monitor => @monitor, :ARGV => @args) do |*args|
        run
      end
    end 

    def run
      Dir.chdir(Rails.root)
      @options[:logger] = Logger.new("#{Rails.root}/log/drb.log", 10, 10.megabytes)
      worker = Rpi::Worker.new(@options)
      worker.start
    rescue => e
      STDERR.puts e.message
      exit 1
    end
  end
end