require "url2yml/version"
require 'uri'
require 'cgi'

module Url2yml
  def self.cassandra_url2yml url, environment
    parser = CassandraUrlParser.new
    if parser.parse url
      parser.to_yml environment 
    else
      "INVALID CASSANDRA URL: #{url}"
    end
  end

  def self.db_url2yml url, environment
    parser = DbUrlParser.new
    if parser.parse url
      parser.to_yml environment 
    else
      "INVALID DB URL: #{url}"
    end
  end

  def self.s3_url2yml url
    parser = S3UrlParser.new
    if parser.parse url
      "access_key_id: #{parser.h_data[:access_key_id]}\n" +
      "secret_access_key: #{parser.h_data[:secret_access_key]}\n" 
    else
      "INVALID S3 URL: #{url}"
    end
  end

  class S3UrlParser
    attr_accessor :h_data

    # s3://access_key_id:secret_access_key
    def parse url
       begin
        @h_data = {}
        match_data = /s3:\/\/(?<access_key_id>[[:alnum:]]+):(?<secret_access_key>[[:alnum:]]+)/.match(url)

        @h_data[:access_key_id] = match_data[:access_key_id]
        @h_data[:secret_access_key] = match_data[:secret_access_key]
        true
       rescue
          msg = "ERROR PARSING S3 URL #{url}: #{$!}"
          if defined?( Rails )
            Rails.logger.error msg
          else
            puts msg
          end
         false
       end
    end
  end

  class CassandraUrlParser
    attr_accessor :h_data

    # cassandra://hostname:port/keyspace
    # TODO: add usr/pwd
    def parse url
       begin
        @h_data = {}

        scheme, remaining_url = url.split( '://' )
        raise "invalid scheme" unless scheme == 'cassandra'
        raise "invalid url" if remaining_url.strip.nil? || remaining_url.strip == ''

        host_port, keyspace = remaining_url.split( '/' )
        raise "no keyspace" if keyspace.nil? || keyspace.strip == ''

        host, port = host_port.split( ':' )

        port = 9160 if port.nil? || post.strip == ''
        @h_data[:host] = host
        @h_data[:port] = port
        @h_data[:keyspace] = keyspace

        true
       rescue
          msg = "ERROR PARSING CASSANDRA URL #{url}: #{$!}"
          if defined?( Rails )
            Rails.logger.error msg
          else
            puts msg
          end
         false
       end
    end

    def to_yml rails_env
      rails_env = (ENV["RAILS_ENV"] || ENV["RACK_ENV"]) if rails_env.nil? || rails_env.strip == ''

      # Very important to always ensure test env has test suffix so we never blow away a
      # db other than test, ALSO allow a development url to have '_development' replaced with
      # '_test' so you don't have to explicitly change URLs when running 'rake spec' etc
      if rails_env == "test"
        keyspace = h_data[:keyspace]
        h_data[:keyspace] = keyspace.gsub( /_development$/, '' ) if keyspace =~ /_development$/
        h_data[:keyspace] = h_data[:keyspace] + '_test' unless h_data[:keyspace]=~ /_test$/
      end
      
      yml = "#{rails_env}:\n"
      [:host, :port, :keyspace].each do |attr|
        v = h_data[attr]
        yml += " #{attr.to_s}: #{v}\n" if v 
      end
      yml
    end
  end

  class DbUrlParser
    attr_accessor :h_data
    
    def parse url
       begin
        @h_data = {}
        uri = URI.parse(url)

        adapter = uri.scheme
        adapter = "postgresql" if adapter == "postgres"
        @h_data[:adapter] = adapter

        @h_data[:database] = (uri.path || "").split("/")[1]

        @h_data[:username] = uri.user
        @h_data[:password] = uri.password

        @h_data[:host] = uri.host

        @h_data[:port] = uri.port

        @h_data[:params] = CGI.parse(uri.query || "")
        
        @h_data[:adapter] && @h_data[:database] && @h_data[:password]
        true
       rescue
          msg = "ERROR PARSING DB URL #{url}: #{$!}"
          if defined?( Rails )
            Rails.logger.error msg
          else
            puts msg
          end
         false
       end
    end

    def to_yml rails_env
      rails_env = (ENV["RAILS_ENV"] || ENV["RACK_ENV"]) if rails_env.nil? || rails_env.strip == ''

      # Very important to always ensure test env has test suffix so we never blow away a
      # db other than test, ALSO allow a development url to have '_development' replaced with
      # '_test' so you don't have to explicitly change URLs when running 'rake spec' etc
      if rails_env == "test"
        database = h_data[:database]
        if database =~ /_development$/
          h_data[:database] = database.gsub( /_development$/, '' ) 
        end

        unless h_data[:database]=~ /_test$/
          h_data[:database] = h_data[:database] + '_test'
        end
      end
      
      yml = "#{rails_env}:\n"
      [:adapter, :database, :username, :password, :host, :port].each do |attr|
        v = h_data[attr]
        yml += " #{attr.to_s}: #{v}\n" if v 
      end
      if h_data[:params]
        h_data[:params].keys.each do |attr|
          v = h_data[:params][attr]
          v = v[0] if v && v.is_a?(Array) && v.size == 1
          yml += " #{attr.to_s}: #{v}\n" if v 
        end
      end
      yml
    end
  end
end
