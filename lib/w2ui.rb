require 'rubygems'
require 'json'
require 'mongo'
require 'pp'
require 'date'
require './lib/dbfast'

include Mongo

def w2ui_pageheader(name)
  schema = find_by("fast.schema","name",name)
  if schema.nil?
     return ("")
     end
  result = String.new
  result << '<!DOCTYPE html>' + "\n"
  result << '<html>' + "\n"
  result << '<head>' + "\n"
  result << '   <title>' + schema["heading"] + '</title>' + "\n"
  result << '   <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />' + "\n"
  result << '   <link rel="stylesheet" id="mainCSS" type="text/css" media="screen" href="/js/w2ui-1.2.min.css" />' + "\n"
  result << '   <link rel="stylesheet" type="text/css" media="screen" href="/css/font-awesome.css" /> ' + "\n"
  result << '   <link rel="stylesheet" type="text/css" media="screen" href="/index.css"/>' + "\n"
  result << '   <script type="text/javascript" src="/js/jquery.min.js"></script>' + "\n"
  result << '   <script type="text/javascript" src="/js/w2ui-1.2.min.js"></script>' + "\n"
  result << "</head>\n"
  result << "<body>\n"
  return result
  end

def w2ui_grid(name)
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

def w2ui_form_html(name)
  schema = find_by("fast.schema","name",name)
  if schema.nil?
     return ("")
     end
  fields = schema["schema"]

  result = String.new
  result << '<div id="' + name + '_form" style="width: 1000px;">' + "\n"
  result << '    <div class="w2ui-page page-0">' + "\n"


  fieldcnt = fields.count
  cnt = 0
  fields.each{|f|
       cnt = cnt + 1
       if f["hidden"] == false
          case f["type"]
             when "String"
                result << '     <div class="w2ui-label">' + f["caption"] + ':</div>' + "\n"
                result << '     <div class="w2ui-field">' + "\n"
                result << '         <input name="' +  f["name"] + '" type="text" maxlength="100"'
                result << ' size="' + f["size"] + '"/>' + "\n"
                result << "     </div>\n"
                end
          end
       }
    result << "   </div>\n"
    result << ' <div class="w2ui-buttons">' + "\n"
    result << '  <input type="button" value="Reset" name="reset">' + "\n"
    result << '  <input type="button" value="Save" name="save">' + "\n"
    result << ' </div>' + "\n"
    result << '</div>' + "\n"
    return result
end

def w2ui_form_js(name)
  schema = find_by("fast.schema","name",name)
  if schema.nil?
     return ("")
     end
  fields = schema["schema"]

  result = String.new
  result << "$('#" + name + "_form').w2destroy(" + '"' + name + '_form");' + "\n"
  result << "$('#" + name + "_form').w2form({" + "\n"
  result << "   name: '" + name + "_form',\n"
  result << "   url: '" + name + ".json',\n"
  result << "   fields: [\n"
  fieldcnt = fields.count
  cnt = 0
  fields.each{|f|
       cnt = cnt + 1
       if f["hidden"] == false
          case f["type"]
             when "String"
                result << "             "
                result << "{ name: '" + f["name"] + "'"
                result << ", type: 'text'" 
                result << " }"
                if cnt < fieldcnt
                   result << ",\n"
                  else
                   result << "\n"
                   end
                end
          end
       }
    result << "            ],\n"
    result << "actions: {\n"
    result << "   reset: function () {\n"
    result << "     this.clear();\n"
    result << "     },\n"
    result << "   save: function () {\n"
    result << "     this.save();\n"
    result << "     }\n"
    result << "   }\n"
    result << "});\n"
    return result
end



