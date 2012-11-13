#!/bin/env ruby
# encoding: utf-8
module Munin
  class RailsRequestDuration < RailsPlugin
    def config
      puts <<-CONFIG
graph_category #{graph_category}
graph_title Request time
graph_vlabel Seconds
graph_args --base 1000 -l 0
graph_info The minimum, maximum and average request times - railsdoctors.com

min.label min
max.label max
average.label avg
CONFIG
      exit 0
    end

    # Gather information
    def run
      ensure_log_file

      # Initialize values
      max_value = 0
      min_value = 1.0/0.0
      cumulative = 0
      hits = 0

      rla = parse_request_log_analyzer_data

      if rla && rla["Request duration"]
        rla["Request duration"].each do |item|
          max_value = item[1][:max] if item[1][:max] > max_value
          min_value = item[1][:min] if item[1][:min] < min_value
          hits += item[1][:hits]
          cumulative += item[1][:sum]
        end
      else
        hits = 1
        min_value = 0
      end

      puts "max.value #{max_value}"
      puts "min.value #{min_value}"
      puts "average.value #{cumulative / hits.to_f}"
    end
  end
end