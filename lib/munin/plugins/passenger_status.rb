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