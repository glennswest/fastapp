require 'rubygems'
require 'sinatra'
require 'json'
require 'cgi'
require 'mongo'

disable :protection

module Helpers
  def html_escape(s)
    CGI.escape_html(s)
  end
end

helpers Helpers

db = Mongo::Connection.new.db('browser')
  
get '/' do
  erb :collections, :locals => { :collections => db.collections.reject { |x| x.name == 'system.indexes' } }
end

post '/' do
  db.create_collection(params[:collection][:name])
  redirect '/'
end

get '/:collection' do
  name = params[:collection]
  collection = db.collection(params[:collection])
  docs = collection.find
  erb :documents, :locals => { :collection => name, :documents => docs, :document => "{\n}" }
end

post '/:collection' do
  name = params[:collection]
  h = JSON.parse(params[:document])
  collection = db.collection(params[:collection])
  id = collection.insert(h, :safe => true)
  redirect "#{name}/#{id}"
end

get '/:collection/:document' do
  name = params[:collection]
  collection = db.collection(name)
  id = BSON::ObjectId(params[:document])
  document = collection.find_one("_id" => id ) || {}
  erb :document, :locals => { :collection =>name, :id => params[:document], 
    :document => JSON.pretty_generate(document) }
end

