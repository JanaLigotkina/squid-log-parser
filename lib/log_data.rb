#!/usr/bin/env ruby

class LogData
  attr_reader :time_stamp, :time_spend_proxy, :ip, :status, :size,
              :method, :url, :user, :hierarchy_code, :mime_type

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
end
