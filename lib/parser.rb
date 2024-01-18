#!/usr/bin/env ruby

require_relative 'log_file_methods'
require_relative 'colorful_output'

class Parser
  include LogFileMethods
  include ColorfulOutput

  attr_reader :all_logs, :filtered_logs, :num_days
  
  def initialize(file_path, num_days)
    @all_logs = read_all_logs(file_path)
    @filtered_logs = prepare_logs(all_logs, num_days)
    @num_days = num_days
  end

  def get_full_data_size(filtered_logs)
    if filtered_logs.empty?
      puts pastel.red("No data for the last #{num_days} days")
      puts pastel.red("Last available date is #{available_dates(all_logs).max.strftime("%d-%m-%Y")}")
      exit
    else
      filtered_logs.map(&:size).sum
    end
  end

  def get_cache_size(filtered_logs)
    status_sizes = Hash.new { |hash, key| hash[key] = { description: '', count: 0, size_kb: 0, size_mb: 0 } }
    special_status_sums = {
      'TCP_HIT + TCP_MEM_HIT' => 0,
      'TCP_MEM_HIT_ABORTED + TCP_HIT_ABORTED' => 0
    }

    filtered_logs.each do |log|
      if log.status =~ /.*HIT.*200$/
        status_sizes[log.status][:description] = get_description(log.status)
        status_sizes[log.status][:count] += 1
        size_kb, size_mb = convert_to_kb_and_mb(log.size)
        status_sizes[log.status][:size_kb] += size_kb
        status_sizes[log.status][:size_mb] += size_mb

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
      size_kb, size_mb = convert_to_kb_and_mb(size)
      [status, 'Special status sum', nil, size_kb, size_mb.round(2)]
    end
  end

  def convert_to_kb_and_mb(size)
    size_kb = size
    size_mb = (size / 1024.0 / 1024.0)
    [size_kb, size_mb]
  end

  def calculate_percentage(cache_sizes, status, full_size_kb)
    status_size = cache_sizes.find { |cache_size| cache_size[0] == status }[3]
    persent = (status_size / full_size_kb) * 100
    persent.round(2)
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
