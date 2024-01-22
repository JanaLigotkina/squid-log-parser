#!/usr/bin/env ruby

module LogFileMethods
  def prepare_logs(logs, count_of_days)
    @prepare_logs ||= logs.select { |log_data| log_data.timestamp >= (Time.now - count_of_days*24*60*60).to_date }
  end

  def available_dates(logs)
    @available_dates ||= logs.map { |log_data| log_data.timestamp }.uniq
  end

  private

  def read_all_logs(file_path)
    data = {}
    data_prepare = []

    lines = File.readlines(file_path)

    lines.each do |line|
      line_data = line.split(' ')

      data[:timestamp] = Time.at(line_data[0].to_f).to_date
      data[:time_spend_proxy] = line_data[1].to_i
      data[:ip] = line_data[2]
      data[:status] = line_data[3]
      data[:size] = line_data[4].to_i
      data[:method] = line_data[5]
      data[:url] = line_data[6]
      data[:user] = line_data[7]
      data[:hierarchy_code] = line_data[8]
      data[:mime_type] = line_data[9]

      data_prepare << Log.new(data)
    end

    data_prepare
  end
end
