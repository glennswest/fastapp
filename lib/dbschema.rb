require 'rubygems'
require 'json'
require 'mongo'
require 'pp'
require 'date'
require './lib/dbfast'

include Mongo

def create_type_descriptions()
      td = Hash.new
      e = Hash.new
      e["type"] = "String"
      e["typecat"] = "simple"
      e["size"] = 255
      e["required"] = false
      e["default"] = ""
      td[e["type"]] = e

      e = Hash.new
      e["type"] = "Integer"
      e["typecat"] = "simple"
      e["size"] = 10
      e["required"] = false
      e["validate"] = false
      e["min"] = 0
      e["max"] = 0
      e["default"] = 0
      td[e["type"]] = e

      e = Hash.new
      e["type"] = "Boolean"
      e["typecat"] = "simple"
      e["default"] = false
      e["required"] = false
      td[e["type"]] = e
      
      e = Hash.new
      e["type"] = "Hash"
      e["typecat"] = "complex"
      td[e["type"]] = e
 
      e = Hash.new
      e["type"] = "TypedHash"
      e["typecat"] = "complex"
      e["contains"] = Array.new
      td[e["type"]] = e

      e = Hash.new
      e["type"] = "Array"
      e["typecat"] = "complex"
      e["contains"] = Array.new
      td[e["type"]] = e
      
end


def create_schema_for_collection(name) 
      table = @db.collection(name)
      c = table.find_one()
      if c.nil?
         return nil
         end
      schema = Hash.new
      schema["name"] = name
      schema["heading"] = name.capitalize
      schema["schemaformat"] = 1
      schema["schemaversion"] = 1
      schema["readonly"] = false
      schema["audit"] = false
      sf = Array.new
      fields = c.keys
      fields.each_with_index {|field, index|
          thefield = Hash.new
          thefield["name"] = field
          thefield["caption"] = field.capitalize
          thefield["size"] = "30%"
          thefield["hidden"] = false
          thefield["readonly"] = false
          thefield["relationship"] = false
          thetype = c[field].class.to_s
          case thetype
            when "BSON::ObjectId"
                 thetype = "ObjectId"
                 thefield["hidden"] = true
                 thefield["readonly"] = true
            end
          thefield["type"] = thetype
          sf << thefield
          }
      schema["schema"] = sf
      
      return(schema)
      end

def check_schema(name)
    schema = find_by("fast.schema","name",name)
    if schema.nil?
       s = create_schema_for_collection(name)
       if !s.nil?
          add("fast.schema",s)
          end
       end
    end

def scan_collections()
      @db.collections.each do | collection |
          name =  collection.name.to_s()
          case name
               when "system.indexes"
               when "fast.schema"
               else 
                check_schema(name)
               end
          end
      end

def generate_javascript(name)
  schema = find_by("fast.schema","name",name)
  if schema.nil?
     return ("")
     end
  fields = schema["schema"]

  result = String.new
  result << "$('#" + name + "').w2grid({" + "\n"
  result << "   name: '" + name + "',\n"
  result << "   url: '" + name + ".json',\n"
  result << "   columns: [\n"
  fieldcnt = fields.count
  cnt = 0
  fields.each{|f|
       cnt = cnt + 1
       if f["hidden"] == false
          case f["type"]
             when "String"
                result << "             "
                result << "{ field: '" + f["name"] + "'"
                result << ", caption: '" + f["caption"] + "', "
                result << "size: '" + f["size"] + "' }"
                if cnt < fieldcnt
                   result << ",\n"
                  else
                   result << "\n"
                   end
                end
          end
       }
    result << "            ]\n"
    result << "});\n"
    return result
end

def init_schema()
    db = Dbfast()
    scan_collections()
    end
