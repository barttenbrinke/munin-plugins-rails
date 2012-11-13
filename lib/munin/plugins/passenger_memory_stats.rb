#!/bin/env ruby
# encoding: utf-8
module Munin
  class PassengerMemoryStats < RequestLogAnalyzerPlugin    
    def ensure_configuration
      require_passenger_gem
      require_passenger_memory_stats
      
      super
    end

    def config
      memory_info = open('/proc/meminfo', 'r') do |lines|
        lines.inject({}) do |h, line|
          matched = line.match(/^([\w_\(\)]+):\s+(\d+)/)
          h[matched[1].to_sym] = matched[2].to_i * 1024
          h
        end
      end
      upper_limit = memory_info[:MemTotal]
      puts <<-CONFIG
graph_category #{graph_category}
graph_title Passenger memory stats
graph_vlabel Bytes
graph_args --base 1000 -l 0 --upper-limit #{upper_limit}
graph_info The memory used by passenger instances on this application server

memory.label memory
CONFIG
      exit 0
    end

    # Collect the data
    # <tt>debug</tt> Show debug information
    def run
      stats = run_command(passenger_memory_stats, debug)

      #### Total private dirty RSS: 81.81 MB
      stats =~ /RSS:\s*([\d\.]+)\s*MB\Z/m
      memory = ($1.to_f * 1024 * 1024).to_i
      puts "memory.value #{memory}"
    end
  end
end