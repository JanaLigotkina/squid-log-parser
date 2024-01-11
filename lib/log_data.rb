#!/usr/bin/env ruby

class LogData
  def initialize(log_data)
    @time_stamp = log_data[:time_stamp]
    @time_spend_proxy = log_data[:time_spend_proxy]
    @ip = log_data[:ip]
    @status = log_data[:status]
    @size = log_data[:size]
    @method = log_data[:method]
    @url = log_data[:url]
    @user = log_data[:user]
    @hierarchy_code = log_data[:hierarchy_code]
    @mime_type = log_data[:mime_type]
  end

  def read_logs

  end

  def get_log_data
    @log_data
  end
end
