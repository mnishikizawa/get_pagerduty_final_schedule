#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'date'
require 'bundler'
Bundler.require

Dotenv.load '.env'

timezone = 'Asia/Tokyo'
day = Date.today
bom = (Date::new(day.year,day.month, 1) << 1)
#eom = (Date::new(day.year,day.month, 1) - 1)
eom = Date::new(day.year,day.month, 1)

if ENV['PD_API_TOKEN'] == nil
  puts "ENV Variables not set"
  exit 1
end

id = {"PRRRRRR" => "DEV", "WWWWWWW" => "DBA"}

id.each_key do |key|
  endpoint = "https://api.pagerduty.com/schedules/#{key}?#{timezone}&since=#{bom}&until=#{eom}"
  uri = URI.parse(endpoint)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Get.new(uri.request_uri)
  req['Accept'] = "application/vnd.pagerduty+json;version=2"
  req['Authorization'] = "Token token=#{ENV['PD_API_TOKEN']}"
  res = http.request(req)
  puts id[key]
  resj = JSON.parse(res.body)['schedule']['final_schedule']['rendered_schedule_entries']

  resj.each do |p|
    puts p['start'] + ',' + p['end'] + ',' + p['user']['summary']
  end

end
