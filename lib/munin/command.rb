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
command <%= ruby_path %> %c
env.passenger_status /usr/bin/env GEM_PATH=<%= gem_path %> GEM_HOME=<%= gem_home %> PATH=<%= path %> <%= passenger_status_path %>
env.passenger_memory_stats /usr/bin/env GEM_PATH=<%= gem_path %> GEM_HOME=<%= gem_home %> PATH=<%= path %> <%= passenger_memory_stats_path %>
env.graph_category <%= graph_category %>
DATA

    RAILS_PLUGIN_CONFIG = <<-DATA
[<%= plugin_target_name %>]    
env.log_file <%= options[:log_file] %>
user root
command <%= ruby_path %> %c
env.request_log_analyzer /usr/bin/env GEM_PATH=<%= gem_path %> GEM_HOME=<%= gem_home %> PATH=<%= path %> <%= request_log_analyzer_path %>
env.graph_category <%= graph_category %>
DATA

    PASSENGER_CATEGORY = "Passenger"

    def install_application(args)
      app_name = args.shift
      log_file = args.shift
      ruby_path = `which ruby`[0...-1]
      RAILS_PLUGINS.each do |plugin|
        plugin_target_name = [app_name, plugin].join("_")
        add_plugin(plugin, plugin_target_name)
        add_plugin_config(plugin_target_name, app_name, ruby_path, `which request-log-analyzer`, `echo $GEM_PATH`[0...-1], `echo $GEM_HOME`[0...-1], `echo $PATH`[0...-1], RAILS_PLUGIN_CONFIG, :log_file => log_file)
      end      
    end

    def install_passenger_plugins
      ruby_path = `which ruby`[0...-1]
      PASSENGER_PLUGINS.each do |plugin|
        add_plugin(plugin, plugin)
        add_passenger_plugin_config(plugin, PASSENGER_CATEGORY, ruby_path, `echo $GEM_PATH`[0...-1], `echo $GEM_HOME`[0...-1], `echo $PATH`[0...-1], `which passenger_status`[0...-1], `which passenger_memory_stats`[0...-1],PASSENGER_PLUGIN_CONFIG)
      end
    end

    def add_plugin_config(plugin_target_name, graph_category, ruby_path, request_log_analyzer_path, gem_path, gem_home, path, config_template, options = {})
      FileUtils.mkdir_p(munin_plugin_config_path)      
      template = ERB.new config_template
      File.open(File.join(munin_plugin_config_path, plugin_target_name), "w+") do |file|
        file << template.result(binding)      
      end
    end

    def add_passenger_plugin_config(plugin_target_name, graph_category, ruby_path, gem_path, gem_home, path, passenger_status_path, passenger_memory_stats_path, config_template, options = {})
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