require 'rubygems'
require 'sinatra'
require 'json'
require 'cgi'
require 'mongo'

disable :protection
enable :method_override

module Helpers
  def escape_html(h)
    CGI.escapeHTML(h.to_json)
  end
  def exclude_id(d)
    d.reject { |k,v| k == "_id" }
  end
  def truncate(s,n)
    return s if s.length < n
    n -= 4
    s[0..n] + "..."
  end
  def max(a,b)
    a > b ? a : b
  end
end

helpers Helpers

if ENV['VCAP_SERVICES']
  service_type = "mongodb-1.8";
  json = JSON.parse(ENV['VCAP_SERVICES']);
  credentials = json[service_type][0]["credentials"]
  puts credentials.inspect
  conn = Mongo::Connection.new( credentials['host'], credentials['port'])
  conn.add_auth( credentials['db'], credentials['username'], credentials['password'])
  db = conn.db(credentials['db'])
else
  db = Mongo::Connection.new.db('browser')
end

get '/' do
  headers["Cache-Control"] = "private" 
  erb :collections, :locals => { :collections => db.collections.reject { |x| x.name =~ /system\./ } }
end

post '/' do
  name = params[:collection]
  db.create_collection(name) if name
  redirect '/'
end

get '/:collection' do
  headers["Cache-Control"] = "private" 
  name = params[:collection]
  collection = db.collection(params[:collection])
  skip = ( params[:skip] || "0" ).to_i
  skip = 0 if skip < 0
  page_size = 16
  docs = collection.find({},{:skip => skip, :limit => page_size})
  erb :documents, :locals => { 
    :collection => name, 
    :documents => docs, 
    :document => "{\n}", 
    :skip => skip, 
    :count => collection.count,
    :page_size => page_size 
    }
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
  headers["Cache-Control"] = "private" 
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
