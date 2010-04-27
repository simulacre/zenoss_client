require "yaml"
module Test
  module Base
    class Run < Test::Unit::TestCase
      self.test_order         = :defined

      def setup
      end # setup

      
      def teardown
      end # teardown

      
      def self.startup
        @@params = YAML.load_file('base/params.yml')
        @@user            = $user || @@params[:zenoss_server][:user]
        @@password        = $password || @@params[:zenoss_server][:password]
        @@base_uri        = $base_uri || @@params[:zenoss_server][:base_uri]
        
        puts "user: #{@@user}; password: #{@@password}; base_uri: #{@@base_uri}" if $verbose >= 1
      end # self.startup

      
      def self.shutdown
      end # self.shutdown

      # It would be really nice if we could test for warnings
      # http://www.oreillynet.com/ruby/blog/2008/02/structured_warnings_now.html
      #test "no warnings thrown on require" do
      #  assert_no_warnings { require 'lib/zenoss' }
      #end

      test "user not nil" do
        assert_not_nil(@@user)
      end

      test "password not nil" do
        assert_not_nil(@@password)
      end

      test "set Zenoss auth" do
        assert_nothing_thrown { ::Zenoss.set_auth(@@user, @@password) }
      end
      
      test "base_uri set" do
        assert_not_nil(@@base_uri)
      end
      
      test "set Zenoss uri" do
        assert_nothing_thrown { ::Zenoss.uri(@@base_uri) }
      end
      
    end # Run
  end # Base
end # Test