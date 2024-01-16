#!/usr/bin/env ruby

module LogFileMethods
  def prepare_logs(full_logs, num_days)
    @prepare_logs ||= full_logs.select { |log_data| log_data.time_stamp >= (Time.now - num_days*24*60*60).to_date }
  end

  def available_dates(full_logs)
    @available_dates ||= full_logs.map { |log_data| log_data}.uniq(&:time_stamp).map(&:time_stamp)
  end

  private

  def read_all_logs(file_path)
    log_data = {}
    log_data_array = []

    lines = File.readlines(file_path)

    lines.each do |line|
      line_data = line.split(' ')

      log_data[:time_stamp] = Time.at(line_data[0].to_f).to_date
      log_data[:time_spend_proxy] = line_data[1].to_i
      log_data[:ip] = line_data[2]
      log_data[:status] = line_data[3]
      log_data[:size] = line_data[4].to_i
      log_data[:method] = line_data[5]
      log_data[:url] = line_data[6]
      log_data[:user] = line_data[7]
      log_data[:hierarchy_code] = line_data[8]
      log_data[:mime_type] = line_data[9]

      log_data_array << LogData.new(log_data)
    end

    log_data_array
  end
end
