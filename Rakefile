begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "munin-plugins-rails"
    gemspec.summary = "Plugins for Munin that use passenger and RLA"
    gemspec.email = "andrew@ebertech.ca"
    gemspec.authors = ["Andrew Eberbach", ""]
    gemspec.require_paths = ["lib"]   
    gemspec.executables = %W{munin_passenger_memory_stats munin_passenger_queue munin_passenger_status munin_rails_database_time munin_rails_request_duration munin_rails_request_error munin_rails_requests munin_rails_view_render_time}
    gemspec.files = Dir[
      "lib/**/*.rb",
      "VERSION"
    ]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

