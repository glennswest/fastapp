require "./lib/dbfast.rb"

        db = Dbfast()
        puts "Clearing Mongdo Filesystem"
	@db["fs.files"].remove()
	@db["fs.chunks"].remove()
        puts "Clearing Reports"
	@db["reports"].remove()
    

