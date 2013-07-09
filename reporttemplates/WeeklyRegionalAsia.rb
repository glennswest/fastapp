require "pp"
require "./lib/dbfast.rb"


db = Dbfast()
rptdb = db['_reporttemplate']


r = Hash.new
r["name"] = "WeeklyRegionalReportAsia"
r["filename"] = 'WeeklyRegionalAsia-#{yeardotweek}'
r["reporttitle"] = 'Weekly Regional Report - Asia - #{yeardotweek}'
r["driven_by_field"] = "find_distinct('data','week')"
r["compare"] = "$driven_field < yeardotweek()"
r["setup"] = "set_yeardotweek($driven_field)"
tags = Array.new
tags << '$driven_field'
tags << "Asia"
r["tags"] = tags
c = Array.new
theurl = 'country_week?region=Asia&week=#{yeardotweek}&fields=country,count&page_size=0'
c << {"caption" => "Activity This Week", "url" =>  theurl}
countries = find_onecol("countrycode","Region","Asia","Code")
pp countries
countries.each {|country|
     pp country
     caption = find_value_by("countrycode","Code",country,"Name") + " Trend" 
     theurl =  "country_week?region=Asia&country=#{country}&page_size=0&fields=count,week"
     c << {"caption" => caption, "url" => theurl}
     }
r["components"] = c

countries.each {|country|
     pp country
     caption = find_value_by("countrycode","Code",country,"Name") + " New Customers"
     theurl =  "data?region=Asia&country=#{country}&" + 'week=#{yeardotweek}' + "&page_size=0&fields=ip,organization"
     c << {"caption" => caption, "url" => theurl}
     }
r["components"] = c
pp r

existing = rptdb.find_one('name' => r["name"])
if existing.nil?
   result = rptdb.insert(r)
  else
   result = rptdb.update({"_id" => existing["_id"]},r)
  end
pp result
