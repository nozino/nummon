# index.rb

require 'sinatra'
require 'RRD'

class RRDServer
  def create(rrd_file)
    RRD.create(
               rrd_file,
               "--start", "#{Date.today.to_time.to_i - 10000}",
               "--step", "60",
               "DS:a:GAUGE:60:U:U",
               "DS:b:GAUGE:60:U:U",
               "RRA:AVERAGE:0.5:1:30"
               )
  end
  def update(rrd_file, time, value)
    puts "rrd_file = #{rrd_file}, time = #{time}, value = #{value}"
    RRD.update(rrd_file, "#{time}:#{value}:#{value.to_i * value.to_i}")
    return value
  end

  def graph(key, time)
    @rrd_file = "/root/nummon/nummon/#{key}.rrd"
    RRD.graph(
              "/root/nummon/nummon/#{key}.png",
              "--title", " RubyRRD Demo", 
              "--start", "#{time - 40000}",
              "--end", "#{time}",
              "--interlace", 
              "--imgformat", "PNG",
              "--width=450",
              "DEF:a=#{@rrd_file}:a:AVERAGE",
              "DEF:b=#{@rrd_file}:b:AVERAGE",
              "CDEF:line=TIME,2400,%,300,LT,a,UNKN,IF",
              "AREA:b#00b6e4:beta",
              "AREA:line#0022e9:alpha",
              "LINE3:line#ff0000") 
    return ""
  end
end

@@server = RRDServer.new

set :bind, '0.0.0.0'

get '/' do
  'hello world!'
end

get '/update' do
  @value = params[:value]
  @key = params[:key]
  @rrd_file = "#@key.rrd"
  @time = Time.now.to_time.to_i
  @server = RRDServer.new
  @output = @server.update(@rrd_file, @time, @value)

  "output = #@output, time = #@time"
end

get '/create' do
  @key = params[:key]
  @rrd_file = "#@key.rrd"

  @server = RRDServer.new
  @server.create(@rrd_file)

  "#@rrd_file was created."
end

get '/list' do
end

get '/graph' do
  @key = params[:key]
  @time = Time.now.to_time.to_i

  @server = RRDServer.new
  @server.graph(@key, @time)
end
