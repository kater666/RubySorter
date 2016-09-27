require "./log_sorter"
require "test/unit"
 
class TestFileOperations < Test::Unit::TestCase
 
  @@testRootDirectory = 'D:/repo'
  @@testLogDirectory = 'D:/repo/Logs'

  def self.set_up
	Dir.chdir(@@testLogDirectory)
  	testDirs = %w[ Linux_tests Windows_tests ]
  	testDirs.each { |i| Dir.mkdir(i) unless File.exists?(i) }
  end

  def self.tear_down
  	path = 'D:/repo/Logs'
	Dir.chdir(path)

  	testDirs = %w[ Linux_tests Windows_tests OSX_tests ]
  	testDirs.each { |i| Dir.rmdir(i) if File.exists?(i) }

  	Dir.chdir(@@testRootDirectory)
  end

  def test_get_created_directories
  	self.class.set_up
	
	instance = FileOperations.new
	found = instance.get_created_directories("./")
	expected = %w[ Linux_tests Windows_tests ]
	assert_equal(expected, found)

	self.class.tear_down
  end

  def test_get_group_name
  	searchLine = "THIS LINE IS DIFFERENT ZIUTEK_LINUX_TEST_00 PASSED"

  	instance = FileOperations.new
  	found = instance.get_group_name(searchLine)
  	expected = "Linux_tests"
  	assert_equal(expected, found)
  end
  
  def test_get_root_directory
	Dir.chdir(@@testRootDirectory)

	instance = FileOperations.new
	instance.get_root_directory
	found = instance.rootDirectory
	expected = 'D:/repo'
	assert_equal(expected, found)
		
  end
  
  def test_get_search_directories
	Dir.chdir(@@testLogDirectory)
	
	instance = FileOperations.new
    instance.get_search_directories('./')
    found = instance.searchDirectories
	expected = %w[ TC1001_0000 TC1002_0000 TC1003_0000 ]
	assert_equal(expected, found)
	
	Dir.chdir(@@testRootDirectory)
  end

  def test_get_group_name_from_file
  	path = 'D:/repo/Logs/TC1001_0000'
  	Dir.chdir(path)

  	instance = FileOperations.new
  	found = instance.get_group_name_from_file("TC1001_0000.txt")
  	expected = "Linux_tests"
  	assert_equal(expected, found)

  	Dir.chdir(@@testRootDirectory)
  end

  def test_get_group_name_from_file_WINDOWS
  	path = 'D:/repo/Logs/TC1003_0000'
  	Dir.chdir(path)

  	instance = FileOperations.new
  	found = instance.get_group_name_from_file("TC1003_0000.txt")
  	expected = "Windows_tests"
    assert_equal(expected, found)

  	Dir.chdir(@@testRootDirectory)
  end
end
