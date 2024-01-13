#!/usr/bin/env ruby

require_relative 'lib/log_data'
require_relative 'lib/parser'

require "bundler/inline"
require 'date'
require 'time'

gemfile do
  source 'https://rubygems.org'

  ruby ">= 3.0.0"

  gem "pastel"
  gem "thor"
  gem "tty-table"
end

LOG_FILE_PATH = '/Users/jana/Downloads/access.log'.freeze

class App < Thor
  desc "parse", "Parse log file"
  option :days, type: :numeric, default: 7
  # use: ruby main.rb parse --days=4

  def parse
    parser = Parser.new(LOG_FILE_PATH, options[:days])
    full_size = parser.get_full_data_size(parser.selected_logs)
    cache_size = parser.get_cache_size(parser.selected_logs)

    say pastel.bold.green("Всего за указанный период:  #{full_size/1024/1024} MB ( #{full_size/1024/1024/1024} GB )")
    say pastel.bold.red("#{cache_size}")
  end

  private

  def pastel
    @pastel ||= Pastel.new
  end
end

App.start(ARGV)

