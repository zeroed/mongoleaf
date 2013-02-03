module Mongoleaf::Util
  require 'uri'
  require 'mongo'
  require 'mongoid'

  def self.included(klass)
    include Mongo
    klass.extend self::API::MONGOAPI
  end

  module Constants
    UserPath = "./config/db-user"
  end

  module API

    module MONGOAPI

      include Constants

      def self.included klass
        key
      end

      def key k = nil
        if k
          @key = k
        else
          @key ||= 
          "#{File.open(UserPath,"r") {|l| key = l.readline; key.chomp!}}"
        end
      end

      private :key

      def parse_uri(uri_string)
        return nil unless uri_string && uri_string.size > 0
        (base_uri, query) = uri_string.split('?', 2)
        uri = URI.parse(base_uri)
        return [uri, query]
      end

      def go_to_mongo user, password
        # mongodb://<dbuser>:<dbpassword>@ds035037.mongolab.com:35037/bookmarks
        # mongo_uri = "mongodb://#{user}:#{password}@ds035037.mongolab.com:35037"
        mongo_uri = "mongodb://ds035037.mongolab.com:35037"
        db_name = 'bookmarks'
        db_connection = Mongo::Connection.from_uri(mongo_uri)
        db = db_connection.db(db_name)
        # mongo_client = MongoClient.new("localhost", 27017)
        # db = MongoClient.new("localhost", 27017).db("mydb")
        auth = db.authenticate(user, password)
        item_collection = db.collection("notes")
        doc = {"name" => "MongoDB", "type" => "database", "info" => {"time" => Time.now, "y" => '102'}}
        id = item_collection.insert(doc)
        item_collection.find().each {|i| puts i}
        # db.collection_names
        # coll.find_one
        # coll.find("_id" => id).to_a
      end

    end

  end

end
