require 'grape'
module Weather
  class API < Grape::API
    format :json
    prefix :api
    # content_type :json, 'application/json'

    resources :weather do 
      desc "gz weather"
      get do
        # key = "weather_#{Time.now.strftime '%Y%m%d'}"
        # unless $redis.get(key) && result = JSON.parse($redis.get(key))
        #   result = { today: Run.getData(1), after: Run.getData(2) }
        #   $redis.set(key, result.to_json)
        # end
        result = { today: Run.getNow, after: Run.getData(2) }
      end

      desc "get train location"
      get :train_location do
        key = "train_location"
        unless $redis.get(key) && result = JSON.parse($redis.get(key))
          result = Ticket.get_location
          $redis.set(key, result.to_json)
        end
        result
      end

      desc "get Train ticket"
      params do
        requires :date, type: String, desc: 'Your date.'
        requires :from_station, type: String, desc: '起点站.'
        requires :end_station, type: String, desc: '终点站.'
      end
      get :train_ticket do
        Ticket.get_tickets(params.with_indifferent_access)
      end
    end
  end
end