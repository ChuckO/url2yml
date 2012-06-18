require 'minitest/spec'
require 'minitest/autorun'
$LOAD_PATH << File.expand_path( File.dirname(__FILE__) + "/../lib" )
require 'url2yml'
require 'awesome_print'
 
describe Url2yml do
 
  # describe "when DB url2yml parses a good url" do
  #   it "should friggin work" do
  #     url = "postgresql://dev:blah@192.168.1.5:1000/authentication_db_development"
  #     parser = Url2yml::DbUrlParser.new 
  #     assert parser.parse( url )
  #     assert !parser.h_data.nil?
  #     assert parser.h_data[:host] == '192.168.1.5'
  #     assert parser.h_data[:username] == 'dev'
  #     assert parser.h_data[:password] == 'blah'
  #     assert parser.h_data[:port] == 1000
  #     assert parser.h_data[:database] == 'authentication_db_development'
  #     assert parser.h_data[:adapter] == 'postgresql'

  #     puts Url2yml.db_url2yml url, 'development'  
  #     puts Url2yml.db_url2yml url, 'test'  
  #   end
  # end

  # describe "when DB url2yml parses a bad url" do
  #   it "should raise hell" do
  #     url = "XXX=postgresql://dev:dev@192.168.1.5/authentication_db_development"
  #     parser = Url2yml::DbUrlParser.new 
  #     assert !parser.parse( url )
  #   end
  # end

  # describe "when S3 url2yml parses a good url" do
  #   it "should raise" do
  #     url = "s3://123456:abcdef"
  #     parser = Url2yml::S3UrlParser.new 
  #     assert parser.parse( url )
  #     assert parser.h_data[:access_key_id]
  #     assert parser.h_data[:secret_access_key]
  #     puts Url2yml.s3_url2yml "s3://123456:abcdef"
  #   end
  # end

  describe "when cassandra url2yml parses a good url" do
    it "should work" do
      url = "cassandra://localhost/akeystore"
      parser = Url2yml::CassandraUrlParser.new 
      assert parser.parse( url )
      assert parser.h_data[:host]
      assert parser.h_data[:keystore]

      ap parser.h_data

      puts Url2yml.cassandra_url2yml "cassandra://myhost/akeystore_development", 'development'
      puts Url2yml.cassandra_url2yml "cassandra://myhost/akeystore", 'test'
    end
  end
end
