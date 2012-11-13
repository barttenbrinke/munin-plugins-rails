#!/bin/env ruby
# encoding: utf-8
module Munin
  class RailsRequests < RailsPlugin
    def config
      puts <<-CONFIG
graph_category #{graph_category}
graph_title Processed requests
graph_vlabel Requests per second
graph_info The amount of requests processed by this application server - railsdoctors.com

get.label get
get.draw AREA
post.label post
post.draw STACK
put.label put
put.draw STACK
delete.label delete
delete.draw STACK
CONFIG
      exit 0
    end

    # Gather information
    def run
      ensure_log_file

      # Initialize values
      get_value     = 0
      post_value    = 0
      put_value     = 0
      delete_value  = 0

      # Walk through the 
      File.open(get_request_log_analyzer_file).each_line{ |line|
        if match = line.match(/^\s+GET\:\s(\d+).*/)
          get_value = match[1].to_i
        elsif match = line.match(/^\s+POST\:\s(\d+).*/)
          post_value = match[1].to_i
        elsif match = line.match(/^\s+PUT\:\s(\d+).*/)
          put_value = match[1].to_i
        elsif match = line.match(/^\s+DELETE\:\s(\d+).*/)
          delete_value = match[1].to_i
        end
      }

      puts "get.value #{get_value / interval.to_f}"
      puts "post.value #{post_value / interval.to_f}"
      puts "put.value #{put_value / interval.to_f}"
      puts "delete.value #{delete_value / interval.to_f}"
    end
  end
end