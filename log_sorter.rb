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
	
	def get_group_name_from_file(fileName)
		# fileName - filename or path to the file.txt
		file = File.open(fileName)
		while (line = file.gets)
			found = get_group_name(line)
			if found 
				return found
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

	def get_test_case_id
		# To be implemented.
	end

	def get_test_case_name(searchLine)
		return searchLine.scan(/CASE_.*_[0-9]+/)[0]
	end

	def get_group_name(searchLine)
		@@groups.keys.detect do |i| 
			if searchLine.include? i
				return @@groups[i]
			end
		end
	end

	def get_test_case_status(searchLine)
		statuses = %w[ PASSED FAILED BLOCKED ]
		statuses.detect { |i| return i if searchLine.include? i }		
	end
	
	# def get_test_case(path)
	# 	Dir.chdir(path)
	# 	id = nil
	# 	name = nil
	# 	group = nil
	# 	status = nil
	# 	return TestCase.new(id, name, group, status)
	# end
end

class TestCase

	def initialize(id, name, group=nil, status=nil)
		@id = id
		@name = name
		@group = group
		@status = status
	end

	def id
		return @id
	end

	def name
		return @name
	end

	def group
		return @group
	end

	def status
		return @status
	end
end