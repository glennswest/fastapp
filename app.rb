require 'rubygems'
require 'sinatra'
require 'json'
require 'cgi'
require 'mongo'
require 'pp'


disable :protection
enable :method_override

module Helpers
  def first_col(d)
      d.delete("_id")
      d.each {|key,value|
            return value.to_s
            }
      return("")
  end
  def next_to_col(d)
      cols = String.new
      d.delete("_id")
      d.delete(d.keys[0])
      d.each {|key,value|
            cols << '<td>' + value.to_s + '</td>'
            }
      return(cols)
  end
  def doc_to_col(d)
      cols = String.new
      d.delete("_id")
      d.each {|key,value|
            cols << '<td>' + value.to_s + '</td>'
            }
      return(cols)
  end
  def get_heading(d)
      name = d.collection
      table = @db.collection(name)
      firstrow = table.find_one()
      return headings(firstrow)
  end
  def fieldnames(c)
      headings = c.keys
      headings.delete("_id")
      headings.each_with_index {|heading, index|
          headings[index] = heading.capitalize
          }
      return(headings)
  end
  def headings(c)
      fields = fieldnames(c)
      result = String.new
      fields.each {|thefield|
          result << '<th>' + thefield
          }
      return(result)
  end
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
  db = Mongo::Connection.new.db('logparse-db')
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

  if name.include?("favicon")
     return
     end

  table = db.collection(name)
  firstrow = table.find_one()
  row_headings = headings(firstrow)

  collection = db.collection(params[:collection])
  skip = ( params[:skip] || "0" ).to_i
  skip = 0 if skip < 0
  page_size = 16
  thesearch = Hash.new
  pp params
  params.each {|key,value|
         if key == "q"
            values = value.split(',')
            thekey = values[0]
            thevalue = values[1]
            thesearch[thekey] = thevalue
            end
         }
  pp thesearch
  docs = collection.find(thesearch,{:skip => skip, :limit => page_size})
  erb :documents, :locals => { 
    :collection => name, 
    :documents => docs, 
    :document => "{\n}", 
    :skip => skip, 
    :count => collection.count,
    :page_size => page_size,
    :row_headings => row_headings
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
