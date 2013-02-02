module Mongoleaf::Util
  require 'uri'
  require 'mongo'
  require 'mongoid'

  def self.included(klass)
    include Mongo
    klass.extend self::ClassMethods
  end
  module ClassMethods
    def parse_uri(uri_string)
      return nil unless uri_string && uri_string.size > 0
      (base_uri, query) = uri_string.split('?', 2)
      uri = URI.parse(base_uri)
      return [uri, query]
    end
    def go_to_mongo user, password
      #  mongo ds035037.mongolab.com:35037/bookmarks -u <dbuser> -p <dbpassword> 
      # mongodb://<dbuser>:<dbpassword>@ds035037.mongolab.com:35037/bookmarks
      mongo_client = MongoClient.new("localhost", 27017)
      db = MongoClient.new("localhost", 27017).db("mydb")
      auth = db.authenticate(user, password)
      coll = db.collection("testCollection")
      doc = {"name" => "MongoDB", "type" => "database", "count" => 1, "info" => {"x" => 203, "y" => '102'}}
      id = coll.insert(doc)
      db.collection_names
      coll.find_one
      coll.find("_id" => id).to_a
    end
  end
end
