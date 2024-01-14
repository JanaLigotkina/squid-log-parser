#!/usr/bin/env ruby

module ColorfulOutput
  def pastel
    @pastel ||= Pastel.new
  end
end
