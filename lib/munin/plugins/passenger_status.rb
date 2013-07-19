#!/bin/env ruby
# encoding: utf-8
module Munin
  class PassengerStatus < RequestLogAnalyzerPlugin
    def ensure_configuration
      require_passenger_status
      super
    end

    def config
      status = `#{passenger_status}`

      status =~ /max\s+=\s+(\d+)/
      upper_limit = $1 || 150

      puts <<-CONFIG
graph_category #{graph_category}
graph_title Passenger status
graph_vlabel count
graph_args --base 1000 -l 0 --upper-limit #{upper_limit}
graph_info The amount of active passengers on this application server - railsdoctors.com

sessions.label sessions
max.label max processes
running.label running processes
active.label active processes
CONFIG
      exit 0
    end

    def run
      status = run_command(passenger_status, debug)

      if status =~ /Version : 4/
        run_version4(status)
      else
        run_version3(status)
      end
    end

    private
    def run_version4(status)
      status =~ /Max pool size\s+:\s+(\d+)/
      puts "max.value #{$1}"

      status =~ /Processes\s+:\s+(\d+)/
      puts "running.value #{$1}"

      active_processes = status.scan(/Sessions:\s+(\d+)/).flatten.select { |count| count.to_i != 0 }.size
      puts "active.value #{active_processes}"

      total_sessions = 0
      status.scan(/Sessions: (\d+)/).flatten.each { |count| total_sessions += count.to_i }
      puts "sessions.value #{total_sessions}"
    end

    def run_version3(status)
      status =~ /max\s+=\s+(\d+)/
      puts "max.value #{$1}"

      status =~ /count\s+=\s+(\d+)/
      puts "running.value #{$1}"

      status =~ /active\s+=\s+(\d+)/
      puts "active.value #{$1}"

      total_sessions = 0
      status.scan(/Sessions: (\d+)/).flatten.each { |count| total_sessions += count.to_i }
      puts "sessions.value #{total_sessions}"
    end
  end
end
