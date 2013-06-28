require 'mechanize'
require 'pp'
require './parselog'
require 'curb'

agent = Mechanize.new

@client = MongoClient.new('localhost', 27017)
@db     = @client['fastapp']
log    = @db['logs']

thepath = "http://fedorapeople.org/accesslogs/rdo/" 
page = agent.get(thepath)
page.links.each do |link|
   if link.text.include?(".log")
      filename = link.text
      thelog = log.find_one('name' => filename)
      if thelog.nil?
         thelog = Hash.new
         thelog['name'] = filename
         log.insert(thelog)
         
         webpath = thepath + filename
         localpath = 'tmp/' + filename
         puts "Downloading " + webpath
         curl = Curl::Easy.new(webpath)
         curl.perform
         f = File.open(localpath,'w')
         f.write curl.body_str
         f.close
         puts "Processing " + localpath
         result = ParseLog.new(localpath)
         end
      end
   end

