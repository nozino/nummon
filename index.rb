# index.rb

require 'sinatra'
require 'RRD'

class RRDServer
  @@test_param = 0
  @@rrd_file_master = "web_test.rrd"
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
    RRD.update(rrd_file, "#{time}:#{value}:#{value.to_i * value.to_i}")
    return value
  end

  def set_master (name)
    @@rrd_file_master = name
  end

  def get_master
    return @@rrd_file_master
  end
end

@@server = RRDServer.new

set :bind, '0.0.0.0'

get '/' do
  'hello world!'
end

get '/update' do
  @value = params[:value]
  @rrd_file = params[:rrd_file]
#  @time = params[:time]
  @time = Time.now.to_time.to_i
  puts "#@time"
  @server = RRDServer.new
  @output = @server.update(@rrd_file, @time, @value)

  "output = #@output, time = #@time"
end

get '/create' do
  @rrd_file = params[:rrd_file]

  @server = RRDServer.new
  @server.create(@rrd_file)

  "#@rrd_file was created."
end

get '/get_rrd_file_master' do
  "rrd_file_master = #{@@server.get_master}"
end

get '/set_rrd_file_master' do
  @@server.set_master(params[:rrd_file_master])

  "rrd_file_master = #{@@server.get_master}"
end

get '/list' do
end
