require 'pathname'
require 'fileutils'


class ValueError < StandardError
	attr_reader :object

	def initialize(object)
		@object = object
	end
end


class TestGroup

	attr_accessor :groupName, :testCases, :testCasesCount, :directoryPath, :passed, :blocked, :failed

	def initialize(groupName)
		@groupName = groupName
		@testCases = Array.new
		@testCasesCount = 0
		@directoryPath = String.new
		@passed = 0
		@blocked = 0
		@failed = 0
	end

end


class TestCase

	attr_accessor :id, :testCaseName, :group, :status, :directoryPath

	def initialize(id, testCaseName, group=nil, status=nil, directoryPath)
		@id = id
		@testCaseName = testCaseName
		@group = group
		@status = status
		@directoryPath = directoryPath
	end
	
end


class FileOperations
	
	attr_accessor :rootDirectory, :searchDirectories, :createdDirectories, :requiredDirectories, :testCases, :testGroups
	
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
		@testGroups = Hash.new
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

		return TestCase.new(id, testCaseName, group, status, Dir.pwd)
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
				@testGroups[group] = TestGroup.new(group)
			end
		end
	end

	def update_statuses(group, testCaseStatus)
		if testCaseStatus == "PASSED"
			group.passed += 1
		elsif testCaseStatus == "BLOCKED"
			group.blocked += 1
		elsif testCaseStatus == "FAILED"
			group.failed += 1
		else
			raise ValueError.new(testCaseStatus), "Invalid input value."
		end
	end

end


# ++++++++++++++++MAIN+++++++++++++

def main_set_up
	testLogDirectory = 'D:/repo/Logs'
	testFilesDirectory = 'D:/repo/testFiles'
	Dir.chdir(testLogDirectory)
  	testDirs = %w[ Linux_tests OSX_tests ]
  	testDirs.each { |i| Dir.mkdir(i) unless File.exists?(i) }

  	Dir.entries(testFilesDirectory).each do |dir|
  		unless Dir.entries(testLogDirectory).include? dir
  			FileUtils.cp(dir, testLogDirectory)
  		end
  	end
end

def main_tear_down
    testDirs = %w[ Linux_tests Windows_tests OSX_tests ]
	testDirs.each { |i| Dir.rmdir(i) if File.exists?(i) }
	
	clean = FileOperations.new
	clean.get_search_directories('D:/repo/Logs')
	logsPath = 'D:/repo/Logs'
	Dir.chdir(logsPath)
	clean.searchDirectories.each do |dir|	
		puts ">>>>>>>>>>>>>>>>>>>>>>dir", dir
		
		FileUtils.remove_dir('./#{dir}', force = true)
	end

	testRootDirectory = 'D:/repo'
	Dir.chdir(testRootDirectory)
end


def main
	# Prepare for test.
	main_set_up

	instance = FileOperations.new
	instance.get_root_directory
	instance.get_search_directories(instance.rootDirectory)
	instance.get_created_directories(instance.rootDirectory)

	# Get test cases.
	instance.searchDirectories.each_with_index do |directory, index|
		Dir.chdir(directory)
		#puts "Getting test case in directory number #{index + 1}."
		#print "Should be tc dir. ", Dir.pwd, "\n"

		file = "#{directory}.txt"
		#print "File: ", file, "\n"

		testCase = instance.get_test_case(file)	
		unless instance.testCases.keys.include? testCase.id
			instance.testCases[testCase.id] = testCase 
		end
		
		Dir.chdir(instance.rootDirectory)
	end
	
	instance.get_groups
	
	# Sort test cases into groups.
	instance.testGroups.values.each do |g|
		instance.testCases.values.each do |t|
			if t.group == g.groupName
				g.testCases << t
				instance.update_statuses(g, t.status)
			end
		end

		# Count test cases of specific group.
		g.testCasesCount = g.testCases.length

		# Create group's directory unless it exists. Updated @createdDirectories and group.directoryPath.
		unless instance.createdDirectories.include? g.groupName
			path = "#{instance.rootDirectory}/#{g.groupName}"
			Dir.mkdir(path)
			instance.createdDirectories << g.groupName
			instance.requiredDirectories.delete(g.groupName)
			g.directoryPath = path
		end
	end




	# puts "==============Variables===============", "\n"
	# print "rootDirectory: #{instance.rootDirectory}", "\n"
	# puts ">>>>searchDirectories:<<<<", instance.searchDirectories
	# puts ">>>>createdDirectories:<<<<", instance.createdDirectories
	# puts ">>>>requiredDirectories:<<<<", instance.requiredDirectories
	# puts '>>>>>testCases:<<<<'
	# instance.testCases.values.each { |i| puts i.id }
	# puts '>>>>>testGroups and their testCases:<<<<'
	# instance.testGroups.values.each do |i|
	# 	puts "\nGroup name: #{i.groupName}, testCasesCount: #{i.testCasesCount}"
	# 	puts "Passed: #{i.passed}, Blocked: #{i.blocked}, Failed: #{i.failed}"
	# 	i.testCases.each { |j| puts "#{j.id}, #{j.testCaseName}, status: #{j.status}\n directory path: #{j.directoryPath}" }
	# end
	# print "\n==============End of variables==============="

	main_tear_down
end


main

# unless File.exists? './dupa'
# 	Dir.mkdir('dupa')
# end
# f = File.open('./dupa/siurak', 'w')
# f.write("kupa")
# f.close


# sleep(5)

# FileUtils.remove_dir('./dupa', force = true)