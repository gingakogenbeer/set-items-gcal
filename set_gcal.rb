#!/usr/bin/env ruby
require "json"
require 'time'
load "./gcal.rb"

events = []
File.open("event.json") do |f|
    events = JSON.load(f)
end
gc = GCalendar.new
events.each do |event|
    sTime = Time.parse(event["start"]).iso8601
    eTime = Time.parse(event["end"]).iso8601
    begin
        gc.setCal(event["title"], sTime, eTime, event["locate"])
    rescue => e
        puts "#{e.class}: #{e.message}"
        puts "error for invalid value => How to : gc.setCal('title', '2020-12-31T09:00:00', '2020-12-31T17:00:00', 'place')"
    end
end
