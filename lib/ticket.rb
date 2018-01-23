require "open-uri"
require "json"
require 'net/https'

module Net
  class HTTP
    alias_method :original_use_ssl=, :use_ssl=
    def use_ssl=(flag)
      self.ca_file = "./srca_der.cer"
      self.verify_mode = OpenSSL::SSL::VERIFY_PEER # ruby default is VERIFY_NONE!
      self.original_use_ssl = flag
    end
  end
end

module Ticket
  class << self
    def get_location
      begin
        data = open("https://kyfw.12306.cn/otn/resources/js/framework/station_name.js?station_version=1.8964").read
        locations = data.scan(/@\w+\|[\u4e00-\u9fa5]+\|[A-Z]{3}\|\w+\|\w+\|\d+/)
        codeArray, pystationData = [], {}
        
        locations.each_with_index do |item, index|
          t = item.split("|")
          p t
          codeArray << t[2]
          pystationData[t[2]]= {
            name: t[1],
            code: t[2],
            pinyin: t[3],
            short: t[4],
            other: t[5]
          }
        end

        { name:codeArray, data:pystationData }
      rescue Exception => e
        p e
        {e: e}
      end
    end

    def get_stations(config)
      query_lefttickets = 'czxx/queryByTrainNo?'
        +'train_no='+config.train_no
        +'&from_station_telecode='+config.from_station
        +'&to_station_telecode='+config.end_station
        +'&depart_date='+config.date;
    end

    def get_tickets(config)
      time = 0 
      begin
        query_lefttickets = "leftTicket/queryZ?leftTicketDTO.train_date=#{config[:date]}"+
          "&leftTicketDTO.from_station=#{config[:from_station]}"+
          "&leftTicketDTO.to_station=#{config[:end_station]}"+
          "&purpose_codes=ADULT"
        # response = Net::HTTP.get(URI("https://kyfw.12306.cn/otn/" + query_lefttickets), :read_timeout=>30)
        # uri = URI("https://kyfw.12306.cn/otn/" + query_lefttickets)
        # result = ""
        # Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
        #   request = Net::HTTP::Get.new uri
        #   response = http.request request # Net::HTTPResponse object
        #   p response, "sdfsdfs"
        #   result = JSON.parse(response.body)
        # end
        # p ("https://kyfw.12306.cn/otn/" + query_lefttickets)
        result = open("https://kyfw.12306.cn/otn/" + query_lefttickets).read
        result = JSON.parse(result)
        tickets_array = result["data"]["result"]
        map = result["data"]["map"]

        tickects = []

        tickets_array.each_with_index do |item, index|
          temp = item.split("|")
          tickect = {}

          tickect["status"] = temp[1] # 状态（预订 / 列车运行图调整,暂停发售 / ...）
          tickect["train_no"] = temp[2] # 火车编号
          tickect["tId"] = temp[3]      # Train ID

          tickect["fSation"] = TMapStations(temp[6], map) # From Station Name
          tickect["tSation"] = TMapStations(temp[7], map) # To Station Name

          tickect["sTime"] = temp[8]  # Start Time
          tickect["eTime"] = temp[9]  # End Time
          tickect["tTime"] = temp[10] # Total Time
          tickect["date"] = temp[13]

          tickect["from_station_no"] = temp[16] # 出发地车序
          tickect["to_station_no"] = temp[17] # 目的地车序

          tickect["ruanwo"] = temp[23]  # 软卧
          tickect["ruanzuo"] = temp[24] # 软座
          tickect["wuzuo"] = temp[26] # 无座
          tickect["yingwo"] = temp[28]  # 硬卧
          tickect["yingzuo"] = temp[29] # 硬座

          tickect["scSeat"] = temp[30]  # 二等座
          tickect["fcSeat"] = temp[31]  # 一等座
          tickect["bcSeat"] = temp[32]  # 商务座 / 特等座

          tickect["dongwo"] = temp[33]  # 动卧

          tickect["seat_types"] = temp[35]
          
          tickects << tickect
        end

        return {status: 200, data: tickects}
      rescue Exception => e
        sleep 0.01
        time += 1
        retry if time < 3
        return { status: 500, msg: "连续请求12306网站3次失败。。请稍后重试", backtrack: e}
      end
      
    end

    def TMapStations(code, map)
      p code, map
      if map
        name = map[code]
        return name if name        
      end

      code
    end
  end
end