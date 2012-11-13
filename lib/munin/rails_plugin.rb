#!/bin/env ruby
# encoding: utf-8
module Munin
  class RailsPlugin < RequestLogAnalyzerPlugin

    attr_accessor :interval
    attr_accessor :number_of_lines
    attr_accessor :log_file
    attr_accessor :log_format
    attr_accessor :after_time
    attr_accessor :floor_time
    attr_accessor :temp_folder
    attr_accessor :temp_prefix
    attr_accessor :temp_file_name
    attr_accessor :request_log_analyzer  

    def handle_arguments(args, environment)
      super
      
      self.interval        = environment['interval'] ? environment['interval'].to_i : 300
      self.number_of_lines = environment['lines'] || 50000
      self.log_file        = environment['log_file'] || args[0]
      self.log_format      = environment['log_format'] ? "--format #{environment['log_format']}" : ''
      self.after_time      = (Time.now - interval).strftime('%Y%m%d%H%M%S')
      self.floor_time      = Time.at((Time.now.to_f / interval).floor * interval)

      self.temp_folder     = '/tmp'
      self.temp_prefix     = graph_category == 'App' ? 'rla' : graph_category.downcase
      self.temp_file_name       = "#{temp_prefix}_#{floor_time.to_i}.yml"
      self.request_log_analyzer = environment['request_log_analyzer'] || '/usr/bin/request-log-analyzer'       
    end

    def parse_request_log_analyzer_data
      YAML::load_file( get_request_log_analyzer_file )
    end

    def get_request_log_analyzer_file
      fetch_or_create_yaml_file(log_file, debug)
    end

    def ensure_configuration
      require_request_log_analyzer_gem
      require_yaml_gem
      require_tail_command

      super
    end    
    
    def ensure_log_file
      if log_file == "" || log_file.nil?
        $stderr.puts "Filepath unspecified. Exiting"
        exit 1
      end      
    end

    def fetch_or_create_yaml_file(log_file, debug = false)
      # Clean up any old temp files left in de temp folder
      Dir.new(temp_folder).entries.each do |file_name|
        if match = file_name.match(/^#{temp_prefix}_.*\.yml/)
          if match[0] != temp_file_name
            puts "Removing old cache file: #{file_name}" if debug
            File.delete(temp_folder + "/" + file_name)
          end
        end
      end

      temp_file = temp_folder + "/" + temp_file_name

      # Create temp file rla if needed
      unless File.exists?(temp_file)
        puts "Processing the last #{number_of_lines} lines of #{log_file} which are less then #{interval} seconds old." if debug
        status = `tail -n #{number_of_lines} #{log_file} | #{request_log_analyzer} - --after #{after_time} #{log_format} -b --dump #{temp_file}`

        unless $?.success?
          $stderr.puts "failed executing request-log-analyzer. Is the gem path correct?"
          exit 1
        end
      else
        puts "Processing cached YAML result #{temp_file}" if debug
      end

      return temp_file
    end      
  end
end