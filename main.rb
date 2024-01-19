#!/usr/bin/env ruby

require_relative 'lib/types'
require_relative 'lib/log_data'
require_relative 'lib/parser'
require_relative 'lib/colorful_output'

require "bundler/inline"
require "date"
require "time"

gemfile do
  source 'https://rubygems.org'

  ruby ">= 3.0.0"

  gem "dry-struct"
  gem "pastel"
  gem "thor"
  gem "tty-table"
end

LOG_FILE_PATH = '/Users/jana/Downloads/access.log'.freeze

TCP_HIT             = 'TCP_HIT/200'
TCP_MEM_HIT         = 'TCP_MEM_HIT/200'
TCP_MEM_HIT_ABORTED = 'TCP_MEM_HIT_ABORTED/200'
TCP_HIT_ABORTED     = 'TCP_HIT_ABORTED/200'
TOTAL_CACHE         = 'TCP_HIT + TCP_MEM_HIT'
TOTAL_ABORTED       = 'TCP_MEM_HIT_ABORTED + TCP_HIT_ABORTED'

class App < Thor
  include ColorfulOutput

  desc "available_dates", "Show available dates"

  def available_dates
    parser = Parser.new(LOG_FILE_PATH, 0)
    dates  = parser.available_dates(parser.all_logs)

    say pastel.green("Available dates:")
    dates.each do |date|
      say pastel.yellow(date.strftime("%d-%m-%Y"))
    end
  end

  desc "parse", "Parse log file"
  option :days, type: :numeric, default: 7

  def parse
    parser                     = Parser.new(LOG_FILE_PATH, options[:days])
    full_size_kb, full_size_mb = parser.get_full_data_size(parser.filtered_logs)
    cache_data                 = parser.get_cache_size(parser.filtered_logs)

    say pastel.yellow("\nTotal for the period of #{options[:days]} days:\n")
    say pastel.bold.cyan("#{full_size_kb} kB / #{full_size_mb.round(2)} MB\n")
    say pastel.yellow("Cache sizes for the period of #{options[:days]} days:")

    table = create_table(cache_data)
    say table.render(:unicode, padding: [1, 2, 1, 2])
  end

  private

  def create_table(cache_data)
    headers = [
      pastel.bold.underline.green('Cache Type'),
      pastel.bold.underline.green('Description'),
      pastel.bold.underline.green('Query Count'),
      pastel.bold.underline.green('Size (kB)'),
      pastel.bold.underline.green('Size (MB)'),
      pastel.bold.underline.red('Percent')
    ]

    table = TTY::Table.new(header: headers)

    cache_data.each do |item|
      table << item
    end

    table
  end
end

App.start(ARGV)
