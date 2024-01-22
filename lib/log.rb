#!/usr/bin/env ruby

class Log < Dry::Struct
  attribute :timestamp, Types::Strict::Date
  attribute :time_spend_proxy, Types::Strict::Integer
  attribute :ip, Types::Strict::String
  attribute :status, Types::Strict::String
  attribute :size, Types::Strict::Integer
  attribute :method, Types::Strict::String
  attribute :url, Types::Strict::String
  attribute :user, Types::Strict::String.optional
  attribute :hierarchy_code, Types::Strict::String
  attribute :mime_type, Types::Strict::String
end
