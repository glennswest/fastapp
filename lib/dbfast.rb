require 'rubygems'
require 'json'
require 'mongo'
require 'pp'
require 'date'

include Mongo



   def Dbfast
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
      @db = db
      return db
      end

   def fastappurl()
       if ENV['FASTAPPURL']
          return(ENV['FASTAPPURL'])
          end
       return("localhost:4567")
       end

   def set_yeardotweek(value)
       @forcedyeardotweek = value
       end

   def clear_yeardotweek()
       @forcedyeardotweek = nil
       end

   def yeardotweek()
       if @forcedyeardotweek.nil?
           d = DateTime.now
           the_week = d.cwyear.to_s + '.' + d.cweek.to_s
           return(the_week)
           end
       return @forcedyeardotweek
       end

   def find_by(tblname,key,value)
       if @db.nil?
          Dbfast()
          end
       tbl = @db[tblname]
       existing = tbl.find_one(key => value)
       return(existing)
       end

   def find_value_by(tblname,key,value,valuecol)
       if @db.nil?
          Dbfast()
          end
       tbl = @db[tblname]
       existing = tbl.find_one(key => value)
       return(existing[valuecol])
       end

   def find_onecol(tblname,key,value,cname)
       if @db.nil?
          Dbfast()
          end
       tbl = @db[tblname]
       records = tbl.find(key => value)
       results = Array.new
       records.each {|r|
                     results << r[cname]
                    }
       return(results)
       end

   def find_distinct(tblname,cname)
       if @db.nil?
          Dbfast()
          end
       tbl = @db[tblname]
       values = tbl.distinct(cname)
       return(values)
       end

   def addupdate(tblname,key,value,r)
       if @db.nil?
          Dbfast()
          end
       tbl = @db[tblname]
       existing = tbl.find_one(key => value)
       if existing.nil?
          result = tbl.insert(r)
         else
          result = tbl.update({"_id" => existing["_id"]},r)
         end
       return(result)
       end

   def addunique(tblname,key,value,r)
       if @db.nil?
          Dbfast()
          end
       tbl = @db[tblname]
       existing = tbl.find_one(key => value)
       if existing.nil?
          result = tbl.insert(r)
         else
          return(existing)
         end
       return(result)
       end

   def add(tblname,r)
       if @db.nil?
          Dbfast()
          end
       tbl = @db[tblname]
       result = tbl.insert(r)
       return(result)
       end

   def interpolate(str)
       return(eval("\"" + str + "\""))
       end
