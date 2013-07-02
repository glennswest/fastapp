require 'rubygems'
require './lib/dbfast'
require 'pp'
require 'curl'


       
   def webget(url)
         pp url
         curl = Curl::Easy.new(url)
         curl.perform
         return curl.body_str
         end

   def RegisterReport(thename,url)
       r = Hash.new
       r["name"] = thename
       r["link"] = url
       addupdate("reports","name",thename,r)
       end

   def FastReport(reportname)
       rt = find_by("_reporttemplate","name",reportname)
       shortname = interpolate(rt["filename"])
       filename = interpolate('./' + 'public/reports/' + shortname + ".html")
       f = File.open(filename,"w")
       f << "<h1>" + interpolate(rt["reporttitle"]) + '</h1>'
       cs = rt["components"]
       cs.each {|c|
                f << "<h2>" + interpolate(c["caption"]) + "</h2>"
                f << webget('http://' + fastappurl + '/' + interpolate(c["url"]))
               }
       f.close
       RegisterReport(shortname,'reports/' + shortname + ".html")
       end

set_yeardotweek("2013.26")
x = FastReport("WeeklyRegionalReportAsia")
