#!/usr/bin/env ruby

require_relative 'log_file_methods'
require_relative 'colorful_output'

class Parser
  include LogFileMethods
  include ColorfulOutput

  attr_reader :raw_logs, :filtered_logs, :selected_count_days

  def initialize(file_path, selected_count_days)
    @raw_logs            = read_all_logs(file_path)
    @filtered_logs       = prepare_logs(raw_logs, selected_count_days)
    @selected_count_days = selected_count_days
  end

  def get_full_data_size(filtered_logs)
    if filtered_logs.empty?
      puts pastel.red("No data for the last #{selected_count_days} days")
      puts pastel.red("Last available date is #{available_dates(raw_logs).max.strftime("%d-%m-%Y")}")
      exit
    else
      size_sum = filtered_logs.map(&:size).sum
      convert_to_kb_and_mb(size_sum)
    end
  end

  def get_cache_size(filtered_logs)
    filtered_data    = create_hash
    special_sum_data = create_hash
    full_size_kb     = get_full_data_size(filtered_logs)[0]

    filtered_logs.each do |log|
      if log.status =~ /.*HIT.*200$/
        increase_hash_values(
          filtered_data,
          log.status,
          log.size,
          get_description(log.status),
          calculate_percentage(log.size, full_size_kb)
        )

        status_for_increase = case log.status
                              when TCP_HIT, TCP_MEM_HIT
                                TOTAL_CACHE
                              when TCP_MEM_HIT_ABORTED, TCP_HIT_ABORTED
                                TOTAL_ABORTED
                              end

        if status_for_increase
          increase_hash_values(
            special_sum_data,
            status_for_increase,
            log.size,
            get_description(status_for_increase),
            calculate_percentage(log.size, full_size_kb)
          )
        end
      end
    end

    get_array_of_sizes(filtered_data, special_sum_data)
  end

  private

  def create_hash
    Hash.new { |hash, key| hash[key] = { description: '', count: 0, size_kb: 0, size_mb: 0, percent: 0 } }
  end

  def increase_hash_values(data, status, size, description, percent)
    data[status][:description] = description
    data[status][:count]       += 1
    size_kb, size_mb           = convert_to_kb_and_mb(size)
    data[status][:size_kb]     += size_kb
    data[status][:size_mb]     += size_mb
    data[status][:percent]     += percent
  end

  def calculate_percentage(size, full_size_kb)
    (size.to_f / full_size_kb) * 100
  end

  def get_array_of_sizes(filtered_data, special_sum_data)
    filtered_data.map do |status, data|
      [status, data[:description], data[:count], data[:size_kb], data[:size_mb].round(2), "#{data[:percent].round(2)}%"]
    end + special_sum_data.map do |status, data|
      [status, data[:description], data[:count], data[:size_kb], data[:size_mb].round(2), "#{data[:percent].round(2)}%"]
    end
  end

  def convert_to_kb_and_mb(size_kb)
    size_mb = (size_kb / 1024.0)
    [size_kb, size_mb]
  end

  def get_description(status)
    case status
    when TCP_HIT
      'Local cache'
    when TCP_MEM_HIT
      'Memory cache'
    when TCP_MEM_HIT_ABORTED
      'Memory cache, but aborted'
    when TCP_HIT_ABORTED
      'Local cache, but aborted'
    when TOTAL_CACHE
      'Total cache'
    when TOTAL_ABORTED
      'Total aborted'
    else
      'No description available'
    end
  end
end
