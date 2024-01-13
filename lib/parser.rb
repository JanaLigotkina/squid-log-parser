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

  def calculate_downloaded_data
    sum_selected_logs_size = 0
    
    if selected_logs.empty?
      puts "No data for the last #{num_days} days"
      puts "Last available date is #{available_dates(full_logs).max.strftime("%d-%m-%Y")}"
      nil
    end

    selected_logs.each do |log|
      sum_selected_logs_size += log.size
    end

    sum_selected_logs_size
  end
end
