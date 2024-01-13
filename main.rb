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
    size = parser.calculate_downloaded_data

    say pastel.bold.green("#{size} bytes, #{size/1024} KB, #{size/1024/1024} MB, #{size/1024/1024/1024} GB")
  end

  private

  def pastel
    @pastel ||= Pastel.new
  end
end

App.start(ARGV)

