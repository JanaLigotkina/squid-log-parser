#!/usr/bin/env ruby

require_relative 'log_file_methods'

class Parser
  include LogFileMethods

  attr_reader :full_logs, :selected_logs, :num_days
  
  def initialize(file_path, num_days)
    @full_logs = read_all_logs(file_path)
    @selected_logs = prepare_logs(full_logs, num_days)
    @num_days = num_days
  end

  def get_full_data_size(selected_logs)
    if selected_logs.empty?
      puts "No data for the last #{num_days} days"
      puts "Last available date is #{available_dates(full_logs).max.strftime("%d-%m-%Y")}"
      exit
    else
      selected_logs.map(&:size).sum
    end
  end

  def get_cache_size(selected_logs)
    status_sizes = Hash.new(0)

    selected_logs.each do |log|
      if log.status =~ /.*HIT.*200$/
        status_sizes[log.status] += log.size
      end
    end

    status_sizes
  end
end
