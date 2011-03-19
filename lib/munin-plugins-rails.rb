require 'munin/request_log_analyzer_plugin'
require 'munin/rails_plugin'
require 'munin/command'

Dir.glob(File.join(File.dirname(__FILE__), "munin", "plugins", "*.rb")).each do |file|
  require file
end