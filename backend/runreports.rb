require 'pp'
require "./lib/dbfast"
require "./lib/makereport"

def do_report(rt)
    if !rt["setup"].nil?
       eval(rt["setup"])
       end
    pp $driven_field

    FastReport(rt["name"])
    end

db = Dbfast()
rttbl = db["_reporttemplate"]
rts = rttbl.find()
rts.each {|rt|
          clear_yeardotweek()
          puts "Process " + rt["name"]
          driven_fields = eval(rt["driven_by_field"])
          puts "Driven by:"
          pp driven_fields
          driven_fields.each {|driven_field|
             $driven_field = driven_field
             cstr = String.new(rt["compare"])
             result = eval(cstr)
             if result == true
                if !rt["setup"].nil?
                   eval(rt["setup"])
                   end
                if ReportExists?(rt["name"]) == false
                   puts "Generating Report " + $driven_field
                   pp $driven_field
                   do_report(rt)
                   end
                end
             clear_yeardotweek()
             }
          }


