require 'pathname'


class TestGroup

	attr_reader :groupName, :testCases, :testCasesCount, :directoryPath, :passed, :blocked, :failed

	def initialize(groupName)
		@groupName = groupName
		@testCases = Array.new
		@testCasesCount = Integer
		@directoryPath = String.new
		@passed = Integer
		@blocked = Integer
		@failed = Integer
	end
end


class TestCase

	attr_reader :id, :testCaseName, :group, :status

	def initialize(id, testCaseName, group=nil, status=nil)
		@id = id
		@testCaseName = testCaseName
		@group = group
		@status = status
	end
	
end


class FileOperations
	
	attr_reader :rootDirectory, :searchDirectories, :createdDirectories, :requiredDirectories, :testCases, :testGroups
	
	@@groups = {
		"_LINUX_TEST_" => "Linux_tests",
		"_WINDOWS_TEST_" => "Windows_tests",
		"_OSX_TEST_" => "OSX_tests"
	}

	def groups
		return @@groups
	end

	def initialize
		@rootDirectory = String.new
		@createdDirectories = Array.new
		@searchDirectories = Array.new
		@requiredDirectories = Array.new
		@testCases = Hash.new
		@testGroups = Array.new
	end
	
	def get_created_directories(path)

		dirs = Dir.entries(path)
		@@groups.values.each do |i|
			if dirs.include? i 
				@createdDirectories << i
			end
		end
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

	def get_test_case_id(path)
		id = String(Pathname.new(path).basename)
		id.slice! ".txt"
		return id
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
	
	def get_test_case(path)
		
		searchLine = String.new
		file = File.open(path)
		while (line = file.gets)
			if line.include? "_TEST_"	
				searchLine = line
				break
			end
		end

		id = get_test_case_id(path)
		testCaseName = get_test_case_name(searchLine)
		group = get_group_name(searchLine)
		status = get_test_case_status(searchLine)

		if not @createdDirectories.include? group and not @requiredDirectories.include? group
			@requiredDirectories << group
		end

		return TestCase.new(id, testCaseName, group, status)
	end

	def get_groups
		makeGroups = Array.new
		
		# Existing in current sorting groups are in @createdDirectories and @requiredDirectories
		@createdDirectories.each { |i| makeGroups << i }
		@requiredDirectories.each { |i| makeGroups << i }

		# Add if not in @testGroups
		alreadyCreatedGroupsNames = Array.new
		@testGroups.each { |i| alreadyCreatedGroupsNames << i.groupName }
		
		for group in makeGroups
			unless alreadyCreatedGroupsNames.include? group
				@testGroups << TestGroup.new(group)
			end
		end
		
	end

end


# ++++++++++++++++MAIN+++++++++++++

def main_set_up
	testLogDirectory = 'D:/repo/Logs'
	Dir.chdir(testLogDirectory)
  	testDirs = %w[ Linux_tests OSX_tests ]
  	testDirs.each { |i| Dir.mkdir(i) unless File.exists?(i) }
end

def main_tear_down
    testDirs = %w[ Linux_tests Windows_tests OSX_tests ]
	testDirs.each { |i| Dir.rmdir(i) if File.exists?(i) }
	
	testRootDirectory = 'D:/repo'
	Dir.chdir(testRootDirectory)
end


def main
	main_set_up
	x = FileOperations.new
	x.get_root_directory
	x.get_search_directories(x.rootDirectory)
	x.get_created_directories(x.rootDirectory)

	x.searchDirectories.each_with_index do |directory, index|
		Dir.chdir(directory)
		# puts "Getting test case in directory number #{index + 1}."
		# print "Should be tc dir. ", Dir.pwd, "\n"
		file = directory << '.txt'
		# print "File: ", file, "\n"
		testCase = x.get_test_case(file)
		x.testCases[testCase] = testCase

		Dir.chdir(x.rootDirectory)
	end
	
	x.get_groups
	groups = Array.new
	groups << x.testGroups.each { |i| i.groupName }

	puts "==============Variables==============="
	print "rootDirectory: ", x.rootDirectory, "\n"
	puts ">>>>searchDirectories:<<<<", x.searchDirectories
	puts ">>>>createdDirectories:<<<<", x.createdDirectories
	puts ">>>>requiredDirectories:<<<<", x.requiredDirectories
	puts '>>>>>testCases:<<<<'
	x.testCases.values.each { |i| puts i.id }
	print "==============End of variables==============="

	main_tear_down
end


#main