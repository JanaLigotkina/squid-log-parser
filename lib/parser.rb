#!/usr/bin/env ruby

require_relative 'log_file_methods'
require_relative 'colorful_output'

class Parser
  include LogFileMethods
  include ColorfulOutput

  attr_reader :full_logs, :selected_logs, :num_days
  
  def initialize(file_path, num_days)
    @full_logs = read_all_logs(file_path)
    @selected_logs = prepare_logs(full_logs, num_days)
    @num_days = num_days
  end

  def get_full_data_size(selected_logs)
    if selected_logs.empty?
      puts pastel.red("No data for the last #{num_days} days")
      puts pastel.red("Last available date is #{available_dates(full_logs).max.strftime("%d-%m-%Y")}")
      exit
    else
      selected_logs.map(&:size).sum
    end
  end

  def get_cache_size(selected_logs)
    status_sizes = Hash.new { |hash, key| hash[key] = { description: '', count: 0, size_kb: 0, size_mb: 0 } }
    special_status_sums = {
      'TCP_HIT + TCP_MEM_HIT' => 0,
      'TCP_MEM_HIT_ABORTED + TCP_HIT_ABORTED' => 0
    }

    selected_logs.each do |log|
      if log.status =~ /.*HIT.*200$/
        status_sizes[log.status][:description] = get_description(log.status)
        status_sizes[log.status][:count] += 1
        status_sizes[log.status][:size_kb] += log.size
        status_sizes[log.status][:size_mb] += (log.size / 1024.0 / 1024.0)

        if ['TCP_HIT/200', 'TCP_MEM_HIT/200'].include?(log.status)
          special_status_sums['TCP_HIT + TCP_MEM_HIT'] += log.size
        elsif ['TCP_MEM_HIT_ABORTED/200', 'TCP_HIT_ABORTED/200'].include?(log.status)
          special_status_sums['TCP_MEM_HIT_ABORTED + TCP_HIT_ABORTED'] += log.size
        end
      end
    end

    status_sizes.map do |status, data|
      [status, data[:description], data[:count], data[:size_kb], data[:size_mb].round(2)]
    end + special_status_sums.map do |status, size|
      [status, 'Special status sum', nil, size, (size / 1024.0 / 1024.0).round(2)]
    end
  end

  def get_description(status)
    case status
    when 'TCP_HIT/200'
      'Local cache'
    when 'TCP_MEM_HIT/200'
      'Memory cache'
    when 'TCP_MEM_HIT_ABORTED/200'
      'Memory cache, but aborted'
    when 'TCP_HIT_ABORTED/200'
      'Local cache, but aborted'
    else
      'No description available'
    end
  end
end
