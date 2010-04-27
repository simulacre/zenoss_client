require 'rubygems'
require 'optparse'
require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'

require 'lib/zenoss'

require "test/base/run"

$verbose    = 0
$base_uri   = nil
$user       = ENV['USER']
$password   = nil

$tests = { # add additional tests here
  'base' => Test::Base::Run.suite,
}

prompt = false
def del_arg(a, aa, argv)
  if nil != (i = argv.index(a)) or nil != (i = argv.index(aa))
    argv.delete_at(i + 1)
    argv.delete_at(i)
  end
end

# individual tests can be run by listing them on the command line
opts = OptionParser.new
opts.on("-v", "Verbose output")                                   { $verbose += 1 }
opts.on("-b", "--base_uri [String]", String, "Zenoss base URI")   { |b| $base_uri = b; del_arg('-b', '--base_uri', ARGV) }
opts.on("-u", "--user [String]", String, "User")                  { |u| $user = u; del_arg('-u', '--user', ARGV) }
opts.on("-p", "--password [String]", String, "Password")          { |p| $password = p; del_arg('-p', '--password', ARGV) }
opts.on("-h", "--help", "Show this display") do
  puts opts
  puts "   available tests are:"
  $tests.keys.sort.each { |t| puts "     #{t}"}
  Process.exit
end
$rest = opts.parse(ARGV)


module Test
  class Run
    def Run.suite
      s = Test::Unit::TestSuite.new("Base")
      if $rest.empty?
        $tests.each do |k,t|
          s << t
        end
      else
        $rest.each do |k|
          if $tests[k]
            s << $tests[k]
            ARGV.delete(k)
          end
        end
      end
      s
    end
  end
end # Test

Test::Unit::UI::Console::TestRunner.run(Test::Run)