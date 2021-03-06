module Ruby19
  PROG = '/Users/jim/local/ruby19/bin/ruby'
  GEM_HOME = '/Users/jim/local/ruby19.gems'

  RELEASE_FILES = FileList['bin/rake', 'lib/rake.rb', 'lib/rake/**/*']
  RELEASE_FILES.exclude('lib/rake/lib', 'project.rake', 'lib/rake/plugins', 'lib/rake/contrib')

  SVN = "../thirdparty/ruby"

  def run_tests(files)
    sh "#{PROG} -Ilib lib/rake/rake_test_loader.rb #{files}"
  end

  extend self
end

namespace "ruby19" do
  desc "Ruby Release Files"
  task :release_files do
    puts Ruby19::RELEASE_FILES
  end

  desc "Release Rake Files to Ruby 19 SVN working area"
  task :release => [:check_svn] do
    dirs = Ruby19::RELEASE_FILES.select { |fn| File.directory?(fn) }
    dirs.each do |dir| mkdir_p "#{Ruby19::SVN}/#{dir}" end
    Ruby19::RELEASE_FILES.each do |fn|
      cp fn, "#{Ruby19::SVN}/#{fn}" unless File.directory?(fn)
    end
  end

  desc "Remove Rake from the Ruby 19 SVN"
  task :unrelease => [:check_svn] do
    rm_r "#{Ruby19::SVN}/bin/rake" rescue nil
    rm_r "#{Ruby19::SVN}/lib/rake" rescue nil
    rm_r "#{Ruby19::SVN}/lib/rake.rb" rescue nil
  end

  task :check_svn do
    fail "Cannot find Ruby 1.9 SVN directory: #{Ruby19::SVN}" unless
      File.directory?(Ruby19::SVN) 
  end

  
  namespace "test" do

    desc "Check the file paths"
    task :check do
      raise "Ruby 1.9 executable not found" unless File.exist?(Ruby19::PROG)
      raise "Ruby 1.9 Gem Home not found"   unless File.exist?(Ruby19::GEM_HOME)
    end

    task :env19 => :check do
      ENV['GEM_HOME'] = Ruby19::GEM_HOME
    end

    desc "Describe the Ruby 1.9 version used for testing"
    task :version => [:env19] do
      sh "#{Ruby19::PROG} --version", :verbose => false
      sh "#{Ruby19::PROG} -rubygems -e 'puts \"Gem Path = \#{Gem.path}\"'", :verbose => false
    end

    desc "Run the unit tests in Ruby 1.9"
    task :units => [:env19] do
      test_files = FileList['test/test_*.rb']
      Ruby19.run_tests(test_files)
    end

    desc "Run the functional tests in Ruby 1.9"
    task :functionals => [:env19] do
      test_files = FileList['test/functional.rb']
      Ruby19.run_tests(test_files)
    end

    desc "Run the all the tests in Ruby 1.9"
    task :all => [:env19] do
      test_files = FileList['test/functional.rb', 'test/test_*.rb']
      Ruby19.run_tests(test_files)
    end
  end
end
