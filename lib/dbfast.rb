require 'rubygems'
require 'bundler/setup'
require 'json'
require 'mongo'
require 'pp'
require 'date'

include Mongo



   def Dbfast
       if ENV['OPENSHIFT_APP_NAME']
          service_type = "mongodb-1.8";
          dbname = ENV['OPENSHIFT_APP_NAME']
          db = Mongo::Connection.new( ENV['OPENSHIFT_MONGODB_DB_HOST'],
                                      ENV['OPENSHIFT_MONGODB_DB_PORT']).db(dbname)
          auth = db.authenticate(ENV['OPENSHIFT_MONGODB_DB_USERNAME'],
                                 ENV['OPENSHIFT_MONGODB_DB_PASSWORD'])
else
          db = Mongo::Connection.new.db('fastapp')
end
        @db = db
        @grid = Mongo::GridFileSystem.new(@db)
        return db
        end

   
   def GridFileExists?(filename)
       if @db.nil?
          Dbfast()
          end
       result = @grid.exist?(:filename => filename)
       if result.nil?
          return false
          end
       return true
       end
   def GridFileOpen(filename,mode)
       if @db.nil?
          Dbfast()
          end
       result = @grid.open(filename, mode)
       return result
       end
   def GridFileDelete(filename)
       if @db.nil?
          Dbfast()
          end
       result = @grid.delete(filename)
       return result
       end

   def fastappurl()
       if ENV['OPENSHIFT_APP_DNS']
          return(ENV['OPENSHIFT_APP_DNS'])
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
       begin
         if str.include?('{')
            return(eval("\"" + str + "\""))
           else 
            return(eval(str))
           end
       rescue
          return(str)
          end

       end
