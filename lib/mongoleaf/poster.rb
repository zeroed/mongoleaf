module Mongoleaf::Poster
  require 'net/http'
  require 'uri'
  require 'json'
  require 'pp'
  
  def self.included(klass)
    p "#{Time.now} #{self} included"
    klass.extend self::ClassMethods
  end

  module Constants
    Version = 1
    Endpoint = "https://api.mongolab.com/api/#{Version}/databases/"
    OnlineAPI = "https://support.mongolab.com/entries/20433053-rest-api-for-mongodb"
  end

  def test
    "test #{self}"
  end

  module ClassMethods
    
    def key
      @key ||= 
        "?apiKey=#{File.open("./config/api-key","r") {|l| key = l.readline; key.chomp!}}"
    end

    def databases
      # /databases
      # GET - lists databases linked to the authenticated account
      @url = URI.parse "#{Constants::Endpoint}#{key}"
    end

    def databases_subservices database
      # /databases/<d>
      # GET - lists sub-services for database <d>
    end

    def collections database
      # /databases/<d>/collections
      # GET - lists collections in database <d>
      @url = URI.parse "#{Constants::Endpoint}#{database}/collections/#{key}"
    end
   
    def collection database, collection
      # /databases/<d>/collections/<c>
      # GET - lists objects in collection <c>
      # POST - inserts a new object into collection <c>
      @url = URI.parse "#{Constants::Endpoint}#{database}/collections/#{collection}#{key}"
    end

    def id(database, collection, id, hash={})
      # /databases/<d>/collections/<c>/<id>
      # GET - returns object with _id <id>
      # PUT - modifies object (or creates if new)
      # DELETE - deletes object with _id <id>
      @url = URI.parse "#{Constants::Endpoint}#{database}/collections/#{collection}/id/#{key}"
    end

    def library_master
      @url = URI.parse "#{Constants::Endpoint}/bookmarks/collections/library/master/#{key}"
    end
    
    def select db="bookmarks", coll="library", q={'id'=>'master'}
      # /databases/<db>/collections/<coll>?[q=<query>][&c=true] [&f=<fields>][&fo=true][&s=<order>] [&sk=<skip>][&l=<limit>]
      # GET - lists all objects matching these optional params:
      # q: JSON queryreference
      # c: returns the result count for this query
      # f: set of fields to be returned in each object
      #    (1—include; 0—exclude)
      #    e.g. { "name" : 1, "email": 1 } OR 
      #    e.g. { "comments" : 0 } 
      # fo: return a single object from the result set
      #    (same as 'findOne()' in the mongo shell) 
      # s: sort order (1—asc; -1—desc) 
      #    i.e. { <field> : <order> }
      # sk: number of results to skip in the result set
      # l: limit for the number of results
    end

    def insert db="bookmarks", coll="library", q={'id'=>'master'} 
      # /databases/<d>/collections/<c>?[q=<query>][&m=true] [&u=true]
      # PUT - updates one or all objects matching the query.
      #   payload should contain modifier operations
      # q: JSON queryreference
      # m: apply update to all objects in result set
      #  (by default, only one is updated)
      # u: insert if none match the query (upsert)
    end

    def get
      net = Net::HTTP.new(@url.host, @url.port)
      net.use_ssl = true
      query = Net::HTTP::Get.new(@url.path + '?' + @url.query)
      response = net.request(query)
      case response
        when Net::HTTPBadResponse
          puts "Net::HTTPBadResponse"
        when Net::HTTPRedirection
          # TODO: manage redirect
        else
          # puts "Response code: #{response.code} message: #{response.message} body: #{response.body}"
          @bookmarks = JSON.parse(response.tap{|r| p "#{r.class}"}.body.force_encoding('UTF-8'))#.to_json
      end
    end

    def post hash
      request = Net::HTTP::Post.new(@url.path + '?' + @url.query)
      request.content_type = 'application/json'
      request.body = hash.to_json
      response = net.start {|http| http.request(request)}
      case response
        when Net::HTTPBadResponse
          puts "Net::dResponse ??"
        else
          puts "Response code: #{response.code} message: #{response.message} body: #{response.body}"
      end
      rescue SocketError
        puts "SocketError rescued"
    end

    def get_response 
    end

    def dump
      filename = "reading_marks_#{Time.now.strftime("%Y%m%dT%H%M")}"
      io = File.open("#{filename}.json","w")
      JSON.dump(@bookmarks, io)
    end

    def post_note(hash, key)
        File.open("./config/api-key","r").each_line {|l| key = l; key.chomp!} unless key
      path = "https://api.mongolab.com/api/1/databases/bookmarks/collections/notes?apiKey=#{key}"
      uri = URI.parse(path)
      net = Net::HTTP.new(uri.host, uri.port)
      net.use_ssl = true
      request = Net::HTTP::Post.new("#{uri.path}?#{uri.query}")
      request.content_type = 'application/json'
      request.body = hash.to_json
      response = net.start {|http| http.request(request)}
      case response
        when Net::HTTPBadResponse
          puts "Net::dResponse ??"
        else
          puts "Response code: #{response.code} message: #{response.message} body: #{response.body}"
      end
      rescue SocketError
        puts "SocketError rescued"
    end
  end
end

