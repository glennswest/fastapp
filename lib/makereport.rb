require 'rubygems'
require './lib/dbfast'
require 'pp'
require 'curl'


       
   def webget(url)
         curl = Curl::Easy.new(url)
         curl.perform
         return curl.body_str
         end

   def RegisterReport(thename,url,tags)
       r = Hash.new
       r["name"] = thename
       r["link"] = url
       result = addupdate("reports","name",thename,r)
       tags.each {|t|
            tagvalue = interpolate(t).to_s
            tv = Hash.new
            tv["name"] = tagvalue
            tv["link"] = "tag.link?tag=" + tagvalue + "&fields=name,link"
            result = addupdate("tag","name",tagvalue,tv)
            tl = Hash.new
            tl["name"] = thename
            tl["tag"] = tagvalue
            tl["link"] = url
            result = add("tag.link",tl)
            }
       end

   def ReportExists?(reportname)
       rt = find_by("_reporttemplate","name",reportname)
       shortname = interpolate(rt["filename"])
       filename = interpolate(shortname + ".html")
       return(GridFileExists?(filename))
       end

   def FastReport(reportname)
       rt = find_by("_reporttemplate","name",reportname)
       shortname = interpolate(rt["filename"])
       filename = interpolate(shortname + ".html")
       thetags = Array.new
       rt["tags"].each {|tt|
          thetags << interpolate(tt)
          }
       f = GridFileOpen(filename,"w")
       f.write "<h1>" + interpolate(rt["reporttitle"]) + '</h1>'
       cs = rt["components"]
       cs.each {|c|
                f.write "<h2>" + interpolate(c["caption"]) + "</h2>"
                f.write webget('http://' + fastappurl + '/' + interpolate(c["url"]))
               }
       f.close
       RegisterReport(shortname,'files/' + shortname + ".html",thetags)
       end

# Test the module
if __FILE__ == $0
   set_yeardotweek("2013.26")
   x = FastReport("WeeklyRegionalReportAsia")
   end

