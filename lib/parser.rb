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
      size_sum = filtered_logs.map(&:size).sum
      convert_to_kb_and_mb(size_sum)
    end
  end

  def get_cache_size(filtered_logs)
    filtered_sizes = create_hash
    sum_filtered_sizes = create_hash
    full_size_kb = get_full_data_size(filtered_logs)[0]

    filtered_logs.each do |log|
      if log.status =~ /.*HIT.*200$/
        increase_hash_values(
          filtered_sizes,
          log.status,
          log.size,
          get_description(log.status),
          calculate_percentage(log.size, full_size_kb)
        )

        if [TCP_HIT, TCP_MEM_HIT].include?(log.status)
          status_for_total_cashe = TOTAL_CACHE
          increase_hash_values(
            sum_filtered_sizes,
            status_for_total_cashe,
            log.size,
            get_description(status_for_total_cashe),
            calculate_percentage(log.size, full_size_kb)
          )
        elsif [TCP_MEM_HIT_ABORTED, TCP_HIT_ABORTED].include?(log.status)
          status_for_total_aborted = TOTAL_ABORTED
          increase_hash_values(
            sum_filtered_sizes,
            status_for_total_aborted,
            log.size,
            get_description(status_for_total_aborted),
            calculate_percentage(log.size, full_size_kb)
          )
        end
      end
    end

    get_array_of_sizes(filtered_sizes, sum_filtered_sizes)
  end

  private

  def create_hash
    Hash.new { |hash, key| hash[key] = { description: '', count: 0, size_kb: 0, size_mb: 0, percent: 0 } }
  end

  def increase_hash_values(sizes, status, size, description, percent)
    sizes[status][:description] = description
    sizes[status][:count] += 1
    size_kb, size_mb = convert_to_kb_and_mb(size)
    sizes[status][:size_kb] += size_kb
    sizes[status][:size_mb] += size_mb
    sizes[status][:percent] += percent
  end

  def calculate_percentage(size, full_size_kb)
    (size.to_f / full_size_kb) * 100
  end

  def get_array_of_sizes(filtered_sizes, sum_filtered_sizes)
    filtered_sizes.map do |status, data|
      [status, data[:description], data[:count], data[:size_kb], data[:size_mb].round(2), "#{data[:percent].round(2)}%"]
    end + sum_filtered_sizes.map do |status, data|
      [status, data[:description], data[:count], data[:size_kb], data[:size_mb].round(2), "#{data[:percent].round(2)}%"]
    end
  end

  def convert_to_kb_and_mb(size)
    size_kb = size
    size_mb = (size / 1024.0 / 1024.0)
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
