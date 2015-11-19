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
      values = parse(status)

      upper_limit = values[:max] || 150

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
      values = parse(status)

      puts "max.value %s" % values[:max]
      puts "running.value %s" % values[:running]
      puts "active.value %s" % values[:active]
      puts "sessions.value %s" % values[:sessions]
    end

    private

    def parse(status)
      values = {}

      if status =~ /Version : [45]/
        values[:max] = status =~ /Max pool size\s+:\s+(\d+)/ && $1
        values[:running] = status =~ /Processes\s+:\s+(\d+)/ && $1

        sessions = status.scan(/Sessions: (\d+)/).flatten.map(&:to_i).select { |num| num > 0 }

        values[:sessions] = sessions.inject(&:+) || 0
        values[:active] = sessions.size

      else
        values[:max] = status =~ /max\s+=\s+(\d+)/ && $1
        values[:running] = status =~ /count\s+=\s+(\d+)/ && $1
        values[:active] = status =~ /active\s+=\s+(\d+)/ && $1

        values[:sessions] = status.scan(/Sessions: (\d+)/).flatten.inject(0) { |total, count| total += count.to_i }
      end

      values
    end

  end
end
