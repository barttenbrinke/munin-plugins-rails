begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "munin-plugins-rails"
    gemspec.summary = "Plugins for Munin that use passenger and RLA"
    gemspec.email = "andrew@ebertech.ca"
    gemspec.authors = ["Andrew Eberbach", "Bart ten Brinke"]
    gemspec.require_paths = ["lib"]  
    gemspec.add_dependency "request-log-analyzer" 
    gemspec.executables = %W{request-log-analyzer-munin}
    gemspec.files = Dir[
      "lib/**/*.rb",
      "munin/*",
      "VERSION"
    ]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

