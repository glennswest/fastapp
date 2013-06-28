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
      result = Array.new
      headings.each_with_index {|heading, index|
          if @fields_included.empty? 
             result <<  heading.capitalize
            else
             if @fields_included.include?(heading)
                result <<  heading.capitalize
                end
             end 
          }
      return(result)
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

if ENV['FASTAPP']
  service_type = "mongodb-1.8";
  json = JSON.parse(ENV['FASTAPP']);
  credentials = json[service_type][0]["credentials"]
  puts credentials.inspect
  conn = Mongo::Connection.new( credentials['host'], credentials['port'])
  conn.add_auth( credentials['db'], credentials['username'], credentials['password'])
  db = conn.db(credentials['db'])
else
  db = Mongo::Connection.new.db('fastapp')
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
  @fields_included = Array.new

  collection = db.collection(params[:collection])
  skip = ( params[:skip] || "0" ).to_i
  skip = 0 if skip < 0
  page_size = 16
  thesearch = Hash.new
  
  search_count = 0
  search_url = String.new
  field_projection = Hash.new
  params.each {|key,value|
         pp key
         pp value
         case key
         when "fields"
              thefields = value.split(",")
              fieldvalues = Hash.new
              thefields.each{|f|
                   fieldvalues[f] = 1
                   @fields_included << f
                   }
              field_projection[:fields] = fieldvalues
              pp field_projection
         when "page_size"
              page_size = value.to_i
         when "skip"
         when "splat"
         when "captures"
         when "collection"
         else
            search_url << "&" + key + "=" + value
            search_count = search_count + 1
            if value.include?(",")
              thevalue = value.split(",")
              thesearch[key] = {"$in" => thevalue}
             else 
              thevalue = value
              thesearch[key] = thevalue
              end
            end
         }
  row_headings = headings(firstrow)
  pp thesearch
  pp search_url
  if page_size == 0
     docs = collection.find(thesearch,field_projection)
    else 
     docs = collection.find(thesearch,field_projection,{:skip => skip, :limit => page_size})
     end
  if page_size == 0
   erb :tables, :locals => { 
    :collection => name, 
    :documents => docs, 
    :document => "{\n}", 
    :skip => skip, 
    :count => collection.count,
    :page_size => page_size,
    :row_headings => row_headings,
    :search_url => search_url
    }
   else
    erb :documents, :locals => { 
     :collection => name, 
     :documents => docs, 
     :document => "{\n}", 
     :skip => skip, 
     :count => collection.count,
     :page_size => page_size,
     :row_headings => row_headings,
     :search_url => search_url
     }
   end
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
