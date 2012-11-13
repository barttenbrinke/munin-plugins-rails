#!/bin/env ruby
# encoding: utf-8
module Munin
  class RequestLogAnalyzerPlugin
    attr_accessor :graph_category
    attr_accessor :passenger_memory_stats
    attr_accessor :passenger_status
    attr_accessor :debug
    attr_accessor :environment

    def initialize(args, environment)
      handle_arguments(args, environment)      
      ensure_configuration
      
      if args[0] == "config"
        config
      elsif args[0] == "autoconf"
        autoconf
      end
    end
    
    def handle_arguments(args, environment)
      self.environment = environment
      self.graph_category = environment['graph_category'] || 'App'            
    
      if args[0] == "debug"
        args.shift
        self.debug = true
      end        
    end

    def require_passenger_gem
      require_gem("passenger", ">=2.0")
    end
    
    def run_command(command, debug = false)
      result = `#{command}`

      unless $?.success?
        $stderr.puts "failed executing #{command}"
        exit 1
      end

      puts result if debug      
      
      result
    end
    
    def require_request_log_analyzer_gem
      require_gem("request-log-analyzer", ">=1.1.6")
    end
    
    def require_yaml_gem
      begin
        require 'yaml'
      rescue Exception => e
        puts "no (yaml not found)"
        exit 1
      end           
    end
    
    def require_command(command_name)
      status = `#{command_name}`
      unless $?.success?
        puts "no (error when excuting #{command_name})"
        exit 1
      end        
    end
    
    def require_tail_command
      unless `echo "test" | tail 2>/dev/null`.include?("test")
        puts "no (tail command not found)"
        exit 1
      end      
    end
    
    def require_passenger_status
      self.passenger_status = environment['passenger_status'] || '/usr/local/bin/passenger-status'
      #to use if you have multiple passenger on the host like phusion passenger standalone
      if environment['apache_pid_file']
        self.passenger_status = "cat #{environment['apache_pid_file']} | xargs -0 #{passenger_status}"        
      end
      
      require_command(passenger_status)
    end
    
    def require_passenger_memory_stats
      self.passenger_memory_stats  = environment['passenger_memory_stats'] || '/usr/local/bin/passenger-memory-stats'            
      
      require_command(passenger_memory_stats)
    end
    
    def require_gem(gemname, version = nil)
      begin
        require 'rubygems'
        if version
          gem gemname, version
        else
          gem gemname
        end
      rescue Exception => e
        puts "no (Gem not found: #{e})"
        exit 1
      end      
    end
    
    def ensure_configuration
      
    end
    
    def autoconf
      ensure_configuration
      puts "yes"
      exit 0      
    end
  end
end