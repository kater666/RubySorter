class FileOperations
	
	attr_reader :rootDirectory, :searchDirectories, :createdDirectories, :requiredDirectories
	
	@@groups = {
		"_LINUX_TEST_" => "Linux_tests",
		"_WINDOWS_TEST_" => "Windows_tests"
	}

	def groups
		return @@groups
	end

	def initialize
		@rootDirectory = String.new
		@createdDirectories = Array.new
		@searchDirectories = Array.new
		@requiredDirectories = Array.new
	end
	
	def get_created_directories(path)
		# For each entry in listed directories if it's a directory and it's in groups.values.
		@createdDirectories = Dir.entries(path).each.select { |e| @@groups.values.include? e and File.directory? e }
	end

	def get_group_name(searchLine)
		#THIS LINE IS DIFFERENT ZIUTEK_LINUX_TEST_00 PASSED
		@@groups.keys.each do |i| 
			if searchLine.include? i
				return groups[i] 
			else
				return nil
			end
		end
	end

	def get_root_directory
		@rootDirectory = Dir.pwd.encode("UTF-8")
	end
	
	def get_search_directories(path)
		dirs = Dir.entries(path).select { |entry| File.directory? entry and entry.scan(/TC[0-9]+_[0-9]+/)[0] }
		@searchDirectories = dirs
	end
	
	def get_group_name_from_file(fileName)
		file = File.open(fileName, "r")
		while (line = file.gets) != nil
			puts line
			found = get_group_name(line)
			if found
				print ">>>>>>>>>>>>>>>>>>>>>>>>", found
				return found
			end
		end
		file.close
	end

end

x = FileOperations.new
puts x.groups['_WINDOWS_TEST_']