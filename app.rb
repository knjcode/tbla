# coding: utf-8
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'
require 'open-uri'

# バス停IDハッシュテーブル
stations = {
  "大宮駅西口(おおみやえきにしぐち)"=>"12001",
  "通産省宿舎前(つうさんしょうしゅくしゃまえ)"=>"12047",
  "日進一丁目(にっしんいっちょうめ)"=>"13309",
  "日進公園(にっしんこうえん)"=>"12008"
}

get '/' do
  @stations = stations
  erb :start
end

get '/:start' do |s|
  start = stations.key(s)
  if start
    @stations = stations
    @start = start
    @start_id = s
    erb :end
  end
end

get '/html/:start/:end' do |s,e|
  return get_duration('html',s,e)
end

get '/src/:start/:end' do |s,e|
  content_type 'text/plain'
  get_duration('html',s,e)
end

get '/:start/:end' do |s,e|
  data = { duration: get_duration('json',s,e) }
  json data
end

helpers do

  def get_duration(type, s, e)
    base_url = "http://210.132.101.180/service/tobu/web/"
    url = base_url + "main02.jsp?scd=" + s.to_s + "&s=" + s.to_s + "&e=" + e.to_s + "&k=&k2=&k3="
    html = open(url, "r:Shift_JIS").read
    html.encode!("utf-8")
    case type
    when 'html'
      return html
    when 'json'
      if html =~ /約\d分/
        return $&[1..-2]
      else
        return nil
      end
    end
  end

end
