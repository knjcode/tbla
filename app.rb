require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cross_origin'
require 'sinatra/json'
require 'open-uri'

configure :production do
  require 'newrelic_rpm'
end

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
  get_duration('html',s,e)
end

get '/src/:start/:end' do |s,e|
  content_type 'text/plain'
  get_duration('html',s,e)
end

get '/:start/:end' do |s,e|
  t, d = get_duration('json',s,e)
  data = {
    called_at: Time.now,
    as_at: t,
    departure: s,
    stop: e,
    duration: d
  }
  json data
end

configure do
  enable :cross_origin
end

helpers do

  def get_html(s, e)
    base_url = "http://210.132.101.180/service/tobu/web/"
    url = base_url + "main02.jsp?scd=" + s.to_s + \
	  "&s=" + s.to_s + "&e=" + e.to_s + "&k=&k2=&k3="
    html = open(url, "r:Shift_JIS").read
    html.encode!("utf-8")
    return html
  end

  def get_duration(type, s, e)
    html = get_html(s,e)

    case type
    when 'html'
      return html
    when 'json'
      if html =~ /現在位置情報を提供できませんでした。/
        halt 400, '400 Bad Request'
      end

      if html =~ /該当する路線はありません。/
        halt 404, '404 Not Found'
      end

      if html =~ /([0-9]{2}:[0-9]{2})現在/
        time = $1
      else
        halt 500, 'Internal Server Error'
      end

      if html =~ /約([0-9]+)分/
        duration = $1
      end

      return time, duration

    end
  end

end
