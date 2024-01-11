#!/usr/bin/env ruby

require_relative 'log_file_methods'

class Parser
  include LogFileMethods
  
  def initialize(file_path, nums_lines)
    @log_data = read_logs(file_path, nums_lines)
  end

  def calculate_downloaded_data_last_7_days
    # Расчет скачанных данных по дням за последние 7 дней
  end

  def display_results
    # Вывод результатов
  end
end
