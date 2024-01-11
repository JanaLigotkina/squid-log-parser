#!/usr/bin/env ruby

module LogFileMethods
  def read_logs(file_path, num_lines)
    log_data = {}
    log_data_array = []

    lines = File.readlines(file_path).last(num_lines)

    lines.each_with_index do |line, index|
      line_data = line.split(' ')

      log_data[:time_stamp] = line_data[0]
      log_data[:time_spend_proxy] = line_data[1]
      log_data[:ip] = line_data[2]
      log_data[:status] = line_data[3]
      log_data[:size] = line_data[4]
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
