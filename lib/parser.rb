#!/usr/bin/env ruby

require_relative 'log_file_methods'

class Parser
  include LogFileMethods

  attr_reader :log_data
  
  def initialize(file_path, nums_lines)
    @log_data = prepare_logs(file_path, nums_lines)
  end

  def calculate_downloaded_data
    sum_data_size = 0

    @log_data.each do |log_data|
      sum_data_size += log_data.size
    end

    sum_data_size
  end
end
