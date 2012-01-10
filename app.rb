require 'rubygems'
require 'sinatra'
require 'json'
require 'cgi'
require 'mongo'

disable :protection
enable :method_override

module Helpers
  def html_escape(h)
    CGI.escape_html(h.to_json)
  end
  def exclude_id(d)
    d.reject { |k,v| k == "_id" }
  end
end

helpers Helpers

db = Mongo::Connection.new.db('browser')
  
get '/' do
  erb :collections, :locals => { :collections => db.collections.reject { |x| x.name == 'system.indexes' } }
end

post '/' do
  name = params[:collection]
  db.create_collection(name) if name
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
  collection = db.collection(name)
  id = collection.insert(h, :safe => true)
  redirect "#{name}/#{id}"
end

delete '/:collection' do
  name = params[:collection]
  collection = db.collection(name)
  collection.drop if collection
  redirect "/"
end

get '/:collection/:id' do
  name = params[:collection]
  collection = db.collection(name)
  id = BSON::ObjectId(params[:id])
  document = collection.find_one({ "_id" => id }, { :fields => { "_id" => 0 }} ) || {}
  erb :document, :locals => { :collection =>name, :id => params[:id], 
    :document => JSON.pretty_generate(document) }
end

post '/:collection/:id' do 
  name = params[:collection]
  collection = db.collection(name)
  id = BSON::ObjectId(params[:id])
  h = JSON.parse(params[:document])
  collection.update({ "_id" => id }, { "$set" => h }, :save => true )
  redirect "/#{name}/#{id}"
end

delete '/:collection/:id' do
  name = params[:collection]
  collection = db.collection(name)
  id = BSON::ObjectId(params[:id])
  collection.remove({ "_id" => id })
  redirect "/#{name}"
end
