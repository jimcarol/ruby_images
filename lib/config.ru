require 'rack'
require 'redis'
$redis = Redis.new(host: "116.196.113.206", port: 6379, db: 15)
require "./weather.rb"
require "./reptile.rb"
require "./ticket.rb"

run Weather::API