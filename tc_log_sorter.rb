require "./log_sorter"
require "test/unit"
 
class TestFileOperations < Test::Unit::TestCase
 
  @@testRootDirectory = 'D:/repo'
  @@testLogDirectory = 'D:/repo/Logs'

  def set_up
	Dir.chdir(@@testLogDirectory)
  	testDirs = %w[ Linux_tests Windows_tests OSX_tests ]
  	testDirs.each { |i| Dir.mkdir(i) unless File.exists?(i) }
  end

  def tear_down
  	path = 'D:/repo/Logs'
	  Dir.chdir(path)

  	testDirs = %w[ Linux_tests Windows_tests OSX_tests ]
  	testDirs.each { |i| Dir.rmdir(i) if File.exists?(i) }

  	Dir.chdir(@@testRootDirectory)
  end

  def test_get_created_directories
    set_up
  	
  	instance = FileOperations.new
  	found = instance.get_created_directories("./")
  	expected = %w[ Linux_tests Windows_tests OSX_tests ]
  	assert_equal(expected, found)

  	tear_down
  end

  def test_get_group_name
  	instance = FileOperations.new
    
    searchLineLinux = "THIS LINE IS DIFFERENT ZIUTEK_LINUX_TEST_00 PASSED"
    foundLinux = instance.get_group_name(searchLineLinux)
    expectedLinux = "Linux_tests"

    searchLineWindows = "THIS LINE IS DIFFERENT ZIUTEK_WINDOWS_TEST_00 PASSED"
  	foundWindows = instance.get_group_name(searchLineWindows)
    expectedWindows = "Windows_tests"

  	assert_equal(expectedLinux, foundLinux)
    assert_equal(expectedWindows, foundWindows)

  end

  def test_get_group_name_from_file
    instance = FileOperations.new

    foundLinux = instance.get_group_name_from_file("D:/repo/Logs/TC1001_0000/TC1001_0000.txt")
    expectedLinux = "Linux_tests"
    assert_equal(expectedLinux, foundLinux)

    foundWindows = instance.get_group_name_from_file("D:/repo/Logs/TC1003_0000/TC1003_0000.txt")
    expectedWindows = "Windows_tests"
    assert_equal(expectedWindows, foundWindows)

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
  	expected = %w[ TC1001_0000 TC1002_0000 TC1003_0000 TC1004_0000 ]
  	assert_equal(expected, found)
  	
  	Dir.chdir(@@testRootDirectory)
  end

  def test_get_test_case_name
    instance = FileOperations.new

    searchLineLinux = "THIS LINE IS DIFFERENT CASE_LINUX_TEST_00 PASSED"
    foundLinux = instance.get_test_case_name(searchLineLinux)
    expectedLinux = "CASE_LINUX_TEST_00"

    searchLineWindows = "THIS LINE IS DIFFERENT CASE_WINDOWS_TEST_00 PASSED"
    foundWindows = instance.get_test_case_name(searchLineWindows)
    expectedWindows = "CASE_WINDOWS_TEST_00"

    assert_equal(expectedLinux, foundLinux)
    assert_equal(expectedWindows, foundWindows)
  end

  def test_get_test_case_status
    instance = FileOperations.new

    searchLineLinux = "THIS LINE IS DIFFERENT CASE_LINUX_TEST_00 PASSED"
    foundLinux = instance.get_test_case_status(searchLineLinux)
    expectedLinux = "PASSED"

    searchLineWindows = "THIS LINE IS DIFFERENT CASE_WINDOWS_TEST_00 FAILED"
    foundWindows = instance.get_test_case_status(searchLineWindows)
    expectedWindows = "FAILED"

    assert_equal(expectedLinux, foundLinux)
    assert_equal(expectedWindows, foundWindows)
  end

  def test_get_test_case_data_from_file
    instance = FileOperations.new

    path = "D:/repo/Logs/TC1001_0000/TC1001_0000.txt"
    found = instance.get_test_case(path)

    expectedId = "TC1001_0000"
    expectedName = "CASE_LINUX_TEST_00"
    expectedGroup = "Linux_tests"
    expectedStatus = "PASSED"

    assert_equal(expectedId, found.id)
    assert_equal(expectedName, found.testCaseName)
    assert_equal(expectedGroup, found.group)
    assert_equal(expectedStatus, found.status)

    pathWindows = "D:/repo/Logs/TC1003_0000/TC1003_0000.txt"
    foundWindows = instance.get_test_case(pathWindows)

    expectedIdWindows = "TC1003_0000"
    expectedNameWindows = "CASE_WINDOWS_TEST_00"
    expectedGroupWindows = "Windows_tests"
    expectedStatusWindows = "FAILED"

    assert_equal(expectedIdWindows, foundWindows.id)
    assert_equal(expectedNameWindows, foundWindows.testCaseName)
    assert_equal(expectedGroupWindows, foundWindows.group)
    assert_equal(expectedStatusWindows, foundWindows.status)
  end

  def test_get_groups
    Dir.chdir(@@testLogDirectory)
    instance = FileOperations.new
    instance.get_root_directory
    instance.get_search_directories(instance.rootDirectory)
    instance.get_created_directories(instance.rootDirectory)

    instance.searchDirectories.each_with_index do |directory, index|
      Dir.chdir(directory)
      file = directory << '.txt'

      testCase = instance.get_test_case(file)
      instance.testCases[testCase] = testCase

      Dir.chdir(instance.rootDirectory)
    end

    instance.get_groups
    foundGroupsNames = Array.new
    instance.testGroups.values.each { |i| foundGroupsNames << i.groupName }

    expectedGroupsNames = %w[ Linux_tests Windows_tests OSX_tests ]

    assert_equal(3, instance.testGroups.length)
    assert_equal(expectedGroupsNames, foundGroupsNames)  
  end

end
