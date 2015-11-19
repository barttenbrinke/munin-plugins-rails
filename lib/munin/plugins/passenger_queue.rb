#!/bin/env ruby
# encoding: utf-8
module Munin
  class PassengerQueue < RequestLogAnalyzerPlugin
    def ensure_configuration
      require_passenger_status
      super
    end

    def config
      puts <<-CONFIG
graph_category #{graph_category}
graph_title Passenger queue
graph_vlabel count
graph_args --base 1000 -l 0
graph_info The amount of requests waiting on global queue

requests.label requests
CONFIG
      exit 0
    end

    def run
      status = run_command(passenger_status, debug)
      if status =~ /Version : [45]/
        status =~ /Requests in top-level queue\s+:\s+(\d+)/
        puts "requests.value #{$1}"
      else
        status =~ /Waiting on global queue:\s+(\d+)/
        puts "requests.value #{$1}"
      end
    end
  end
end
