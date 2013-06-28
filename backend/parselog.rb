require 'rubygems'
require 'mongo'
require 'pp'
require 'geoip'
require 'date'
require 'iconv'

include Mongo

@client = MongoClient.new('localhost', 27017)
@db     = @client['fastapp']
@col    = @db['data']

@col.remove

file = File.new("archive/openstack-grizzly-repo.log","r")
while (line = file.gets)
     line_elements = line.split(" ")
     the_ipaddr = String.new(line_elements[1])
     the_date = String.new(line_elements[4][1..-1].split(':')[0])
     d = DateTime.parse(the_date)
     the_week = d.cwyear.to_s + '.' + d.cweek.to_s
     result = @col.find_one('ip' => the_ipaddr)
        
     if(result == nil)
        @geo = Autometal::Geoip.new(the_ipaddr)
        begin
          theorg = String.new
          ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
          untrusted_org = @geo.organization
          theorg = ic.iconv(untrusted_org + ' ')[0..-2]
          if the_ipaddr.include?(":")
              @geo.country = "**"
              theorg = ""
              end
        rescue
          pp the_ipaddr
          pp @geo
          theorg = ''
          end
        ccregion = @db['countrycode']
        country = ccregion.find_one('Code' => @geo.country)
        if country.nil?
           theregion = "Unassigned"
          else
           theregion = country['Region']
          end 
        @col.insert({'ip' => the_ipaddr,
                     'country' => @geo.country,
                     'region'  => theregion,
                     'organization' => theorg,
                     'date' => the_date,
                     'week' => the_week})
        thecountry = String.new(@geo.country)
        if !thecountry.include?(%&can't&)
           # find if we have a country/week record
           @ccweek = @db['country_week']
           result = @ccweek.find_one('country' => @geo.country,
                                     'week' => the_week)
           if (result == nil)
              @ccweek.insert({'region' => theregion,
                              'country' => @geo.country,
                              'week' => the_week,
                              'count' => 1})
             else
              result["count"] = result["count"] + 1
              @ccweek.update({"_id" => result["_id"]},result)
              end
           end 
       end
     end

