require 'fileutils'
require 'erb'
module Munin
  class Command     
    def run(args)
      if args.first == "install"
        install_passenger_plugins
      elsif args.first == "add"
        args.shift
        install_application(args)
      end
    end
    PASSENGER_PLUGINS = %W{munin_passenger_memory_stats munin_passenger_queue munin_passenger_status}
    RAILS_PLUGINS = %W{munin_rails_database_time munin_rails_request_duration munin_rails_request_error munin_rails_requests munin_rails_view_render_time}

    PASSENGER_PLUGIN_CONFIG = <<-DATA
[<%= plugin_target_name %>]
user root
command /usr/local/bin/ruby %c
env.passenger_status '/usr/local/bin/passenger-status'
env.passenger_memory_stats '/usr/local/bin/passenger-memory-stats'    
DATA

    RAILS_PLUGIN_CONFIG = <<-DATA
[<%= plugin_target_name %>]    
env.log_file <%= options[:log_file] %>
user root
command /usr/local/bin/ruby %c
env.request_log_analyzer /usr/local/bin/request-log-analyzer    
DATA

    def install_application(args)
      app_name = args.shift
      log_file = args.shift
      RAILS_PLUGINS.each do |plugin|
        plugin_target_name = [app_name, plugin].join("_")
        add_plugin(plugin, plugin_target_name)
        add_plugin_config(plugin_target_name, RAILS_PLUGIN_CONFIG, :log_file => log_file)
      end      
    end

    def install_passenger_plugins
      PASSENGER_PLUGINS.each do |plugin|
        add_plugin(plugin, plugin)
        add_plugin_config(plugin, PASSENGER_PLUGIN_CONFIG)
      end
    end

    def add_plugin_config(plugin_target_name, config_template, options = {})
      FileUtils.mkdir_p(munin_plugin_config_path)      
      template = ERB.new config_template
      File.open(File.join(munin_plugin_config_path, plugin_target_name), "w+") do |file|
        file << template.result(binding)      
      end
    end

    def add_plugin(plugin_file, plugin_target_name = nil)
      FileUtils.mkdir_p(munin_plugins_path)      
      plugin_target_name ||= plugin_file
      `ln -nsf "#{File.join(munin_dir, plugin_file)}" "#{munin_plugins_path}/#{plugin_target_name}"`      
    end

    def munin_plugins_path
      "/etc/munin/plugins"
    end
    
    def munin_plugin_config_path
      "/etc/munin/plugin-conf.d"
    end    

    def munin_dir
      File.join(File.dirname(__FILE__), "..", "..", "munin")
    end
  end
end