# -*- encoding: shift_jis -*-
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'
require 'open-uri'

get '/' do
  data = { message: "Hello world!" }
  json data
end

get '/nissin-omiya' do
  uri = "http://210.132.101.180/service/tobu/web_kwg/main02.jsp?wid=1&gid=405&scd=13309&s=13309&e=12001&k=&k2=&k3="
  data = { duration: get_duration(uri) }
  json data
end

get '/syukusyamae-omiya' do
  uri = "http://210.132.101.180/service/tobu/web_east/main02.jsp?wid=1&gid=412&scd=12047&s=12047&e=12001&k=&k2=&k3="
  data = { duration: get_duration(uri) }
  json data
end

helpers do
  def get_duration(uri)
    html = open(uri, "r:Shift_JIS").read
    if html =~ /約\d分/
      return $&[1..-2]
    else
      return nil
    end
  end
end

