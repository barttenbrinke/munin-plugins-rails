module Munin
  class RailsRequestError < RailsPlugin
    def config
      puts <<-CONFIG
graph_category #{graph_category}
graph_title Request errors
graph_vlabel Count
graph_info The amount of request errors - railsdoctors.com

error.label error
blocker.label blocker
CONFIG
      exit 0
    end

    # Gather information
    def run
      ensure_log_file

      # Initialize values
      error_value = 0
      blocker_value = 0

      rla = parse_request_log_analyzer_data

      if rla && rla["Failed requests"]
        rla["Failed requests"].each do |item|
          error_value += item[1]
        end
      end

      if rla && rla["Process blockers (> 1 sec duration)"]
        rla["Process blockers (> 1 sec duration)"].each do |item|
          blocker_value += item[1]
        end
      end

      puts "error.value #{error_value}"
      puts "blocker.value #{blocker_value}"
    end
  end
end