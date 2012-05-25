require 'minitest/spec'
require 'minitest/autorun'
$LOAD_PATH << File.expand_path( File.dirname(__FILE__) + "/../lib" )
require 'url2yml'
 
describe Url2yml do
 
  describe "when url2yml parses a good url" do
    it "should friggin work" do
      url = "postgresql://dev:blah@192.168.1.5:1000/authentication_db_development"
      parser = Url2yml::DbUrlParser.new 
      assert parser.parse( url )
      assert !parser.h_data.nil?
      assert parser.h_data[:host] == '192.168.1.5'
      assert parser.h_data[:username] == 'dev'
      assert parser.h_data[:password] == 'blah'
      assert parser.h_data[:port] == 1000
      assert parser.h_data[:database] == 'authentication_db_development'
      assert parser.h_data[:adapter] == 'postgresql'

      puts Url2yml.db_url2yml url, 'development'  
      puts Url2yml.db_url2yml url, 'test'  
    end
  end
 
  describe "when url2yml parses a bad url" do
    it "should raise" do
      url = "XXX=postgresql://dev:dev@192.168.1.5/authentication_db_development"
      parser = Url2yml::DbUrlParser.new 
      assert !parser.parse( url )
    end
  end
end

