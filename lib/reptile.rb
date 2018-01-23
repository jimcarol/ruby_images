require 'net/http'
require 'nokogiri'
require 'fileutils'
require "json"
require 'rufus-scheduler'
require "open-uri"

class Run
  Uri = ARGV[0] || "http://www.weather.com.cn/weather1d/101280101.shtml"
  class << self
    def getData(num)
      html_doc = Nokogiri::HTML(open(Uri))
      data = html_doc.css("#today").first
      case num
      when 1 
         data.css(".tem").first.content.strip
      when 2 
        data.css("ul.clearfix > li").map do |i|
          {
            date: i.search("h1").first.content,
            temp: (i.css(".tem").first.content).strip,
          }
        end
      end
    end

    def getNow
      data = open("http://www.nmc.cn/f/rest/real/59287?_=1516085632041").read()
      JSON.parse(data)["weather"]
    end
  end
end

# result = { today: Run.getData(1), after: Run.getData(2) }
# path = "/data"
# FileUtils.mkdir_p path unless File.exist?(path)

# File.open(path+"/weather.json", "w") do |f|
#   f.write(result.to_json)
# end

# scheduler = Rufus::Scheduler.new

# scheduler.in '1d' do
#   result = { today: Run.getData(1), after: Run.getData(2) }
#   path = "/data"
#   FileUtils.mkdir_p path unless File.exist?(path)

#   File.open(path+"/weather.json", "w") do |f|
#     f.write(result.to_json)
#   end
# end

# scheduler.join