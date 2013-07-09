require "pp"
require "./lib/dbfast.rb"


db = Dbfast()
rptdb = db['_reporttemplate']


countries = find_onecol("countrycode","Region","Asia","Code")
countries.each {|country|
     r = Hash.new
     country_name  = find_value_by("countrycode","Code",country,"Name").delete(' ').capitalize
     r["name"] = "WeeklyReport" + country_name
     r["filename"] = 'WeeklyCountryReport-' + country_name + '-#{yeardotweek}'
     r["reporttitle"] = 'Weekly Country Report - ' + country_name + ' - #{yeardotweek}'
     r["driven_by_field"] = "find_distinct('data','week')"
     r["compare"] = "$driven_field < yeardotweek()"
     r["setup"] = "set_yeardotweek($driven_field)"
     tags = Array.new
     tags << "$driven_field"
     tags << country
     r["tags"] = tags
     caption = country_name + " Trend"
     c = Array.new
     theurl =  "country_week?region=Asia&country=#{country}&page_size=0&fields=count,week"
     c << {"caption" => caption, "url" => theurl}
     caption = country_name + " New Customers"
     theurl =  "data?region=Asia&country=#{country}&" + 'week=#{yeardotweek}' + "&page_size=0&fields=ip,organization"
     c << {"caption" => caption, "url" => theurl}
     r["components"] = c
     puts "Updating Report " + r["name"]
     existing = rptdb.find_one('name' => r["name"])
     if existing.nil?
        result = rptdb.insert(r)
      else
        result = rptdb.update({"_id" => existing["_id"]},r)
      end
     }
