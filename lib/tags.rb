require 'Dbfast'
require 'pp'


def tag(value,desc,url)
	t = Hash.new
        t["tag"] = value
        t["description"] = desc
        t["url"] = "url"
        add("tagcloud",t)
        t = Hash.new
        t["name"] = value
        t["url"] = "/tagcloud/?tag=" + value
        add_unique("tag",t)
        end
