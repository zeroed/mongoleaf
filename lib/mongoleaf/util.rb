module Mongoleaf::Util
  require 'uri'
  require 'mongo'
  require 'mongoid'
  
  def self.included(klass)
    include Mongo
    p "#{Time.now} #{self} included"
    klass.extend self::API::MONGOAPI
  end

  module MongoConstants
    UserKeyPath = "./config/db-user"
    MongolabUrl = "mongodb://ds035037.mongolab.com:35037"
    MongolabUser = "web_user|web_user"
  end

  module API

    module MONGOAPI

      include MongoConstants

      def self.included klass
        user_key
      end

      def user_key k = nil
        if k
          @user_key = k
        else
          @user_key ||= MongolabUser
          # "#{File.open(UserKeyPath,"r") {|l| key = l.readline; key.chomp!}}"
        end
        @user, @password = @user_key.split '|'
      end

      private :user_key

      def parse_uri(uri_string)
        return nil unless uri_string && uri_string.size > 0
        (base_uri, query) = uri_string.split('?', 2)
        uri = URI.parse(base_uri)
        return [uri, query]
      end

      def connect db_name = 'bookmarks'
        user_key #TODO: refactor this mess...
        mongo_uri = MongolabUrl
        db_name = 'bookmarks'
        db_connection = Mongo::Connection.from_uri(mongo_uri)
        db = db_connection.db(db_name)
        auth = db.authenticate(@user, @password)
        return db
      end

      def collection_names database = 'bookmarks'
        connect(database).collection_names.to_a
      end

      def insert_to_mongo item
        db = connect
        item_collection = db.collection("notes")
        doc = item.merge ( {:timestamp => Time.now})
        id = item_collection.insert(doc)
        item_collection.find().to_a #.each {|i| puts i}
      end

      def insert_item item, collection_name = 'notes', database = 'bookmarks'
        collection = connect(database).collection(collection_name)
        begin
          id = collection.insert(item.merge({:timestamp => Time.now}))
        rescue Mongo::OperationFailure => failure
          failure
        else
         collection.find("_id" => id).to_a
        end
      end

      def update_item id, item, collection_name = 'notes', database = 'bookmarks'
        collection = connect(database).collection(collection_name)
        collection.update({'_id' => id}, item.merge({:timestamp => Time.now}))
        collection.find("_id" => id).to_a
      end

      def update_item_and_value id, key, value, collection_name = 'notes', database = 'bookmarks'
        collection = connect(database).collection(collection_name)
        collection.update({"_id" => id}, {'$set' => {key => value}})
        collection.find("_id" => id).to_a
      end

      def find_all collection_name = 'notes', database = 'bookmarks'
        collection = connect(database).collection(collection_name)
        collection.find.to_a
      end

      def find_by_id id, collection_name = 'notes', database = 'bookmarks'
        collection = connect(database).collection(collection_name)
        collection.find("_id" => id).to_a
      end

      def remove_by_id id, collection_name = 'notes', database = 'bookmarks' 
        collection = connect(database).collection(collection_name)
        collection.remove("_id" => id) if id
      end

      def count_collection collection_name = 'notes', database = 'bookmarks'
        collection = connect(database).collection(collection_name)
        collection.find.to_a
      end

    end

  end

end
