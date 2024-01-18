#!/usr/bin/env ruby

require_relative 'lib/types'
require_relative 'lib/log_data'
require_relative 'lib/parser'
require_relative 'lib/colorful_output'

require "bundler/inline"
require 'date'
require 'time'

gemfile do
  source 'https://rubygems.org'

  ruby ">= 3.0.0"

  gem "dry-struct"
  gem "pastel"
  gem "thor"
  gem "tty-table"
end

LOG_FILE_PATH = '/Users/jana/Downloads/access.log'.freeze

class App < Thor
  include ColorfulOutput

  desc "available_dates", "Show available dates"
  def available_dates
    parser = Parser.new(LOG_FILE_PATH, 0)
    dates  = parser.available_dates(parser.full_logs)

    say pastel.green("Available dates:")
    dates.each do |date|
      say pastel.yellow(date.strftime("%d-%m-%Y"))
    end
  end

  desc "parse", "Parse log file"
  option :days, type: :numeric, default: 7
  def parse
    parser      = Parser.new(LOG_FILE_PATH, options[:days])
    full_size   = parser.get_full_data_size(parser.filtered_logs).to_f
    full_size_kb, full_size_mb = parser.convert_to_kb_and_mb(full_size)
    cache_sizes = parser.get_cache_size(parser.filtered_logs)

    percent_success = parser.calculate_percentage(cache_sizes, 'TCP_HIT + TCP_MEM_HIT', full_size_kb)
    percent_aborted = parser.calculate_percentage(cache_sizes, 'TCP_MEM_HIT_ABORTED + TCP_HIT_ABORTED', full_size_kb)

    table = TTY::Table.new(
      header:
      [
       pastel.yellow('Cache Type'), pastel.yellow('Description'), pastel.yellow('Query Count'),
       pastel.yellow('Size (kB)'), pastel.yellow('Size (MB)')
      ]
    )
    cache_sizes.each do |cache_size|
      table << cache_size
    end

    say pastel.green("Total for the period of #{options[:days]} days:\n#{full_size_kb} kB ( #{full_size_mb.round(2)} MB )\n")
    say pastel.green("Percentage of 'TCP_HIT + TCP_MEM_HIT' to total size: #{percent_success}%")
    say pastel.green("Percentage of 'TCP_MEM_HIT_ABORTED + TCP_HIT_ABORTED' to total size: #{percent_aborted}%")
    say pastel.yellow("Cache sizes for the period of #{options[:days]} days:")
    say table.render(:unicode, padding: [0, 1])
  end
end

App.start(ARGV)


