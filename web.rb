require 'bundler'
require 'sinatra'
require 'slim'
require './model'
require './elephant'

configure :production do
  DataMapper.setup(:default, ENV["DATABASE_URL"])
  database_upgrade!
end

configure :test, :development do
  DataMapper.setup(:default, "yaml:///tmp/on-sided-pao")
  database_upgrade!
end

get '/' do
  @targets = Target.all
  @request_methods = Target.request_methods
  slim :index
end

post '/add_target' do
  target = Target.new#.create(:url => params[:url], :name => params[:name])
  target.url = params[:url]
  target.name = params[:name]
  target.span = params[:span]
  target.request_method = params[:request_method]
  target.save!
  redirect '/', 302
end

post '/delete_target' do
  target = Target.get(params[:id])
  target.destroy!
  redirect '/', 302
end

rampage

