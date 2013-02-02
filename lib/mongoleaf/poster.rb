module Mongoleaf::Poster
  require 'net/http'
  require 'uri'
  require 'json'
  require 'pp'
  
  def self.included(klass)
    p "#{Time.now} #{self} included"
    klass.extend self::API
  end

  module Constants
    Version = 1
    Endpoint = "https://api.mongolab.com/api/#{Version}/databases/"
    OnlineAPI = "https://support.mongolab.com/entries/20433053-rest-api-for-mongodb"
    KeyPath = "./config/api-key"
    NoteUrl = "#{Endpoint}bookmarks/collections/notes/"
  end

  module API

    include Constants

    def self.included klass
      key
    end

    def key k = nil
      if k
        @key = k
      else
        @key ||= 
        "?apiKey=#{File.open(KeyPath,"r") {|l| key = l.readline; key.chomp!}}"
      end
    end

    private :key

    def databases
      # /databases
      # GET - lists databases linked to the authenticated account
      @url = URI.parse "#{Endpoint}#{key}"
    end

    def databases_subservices database
      # /databases/<d>
      # GET - lists sub-services for database <d>
      @url = URI.parse "#{Endpoint}#{database}/#{key}"
    end

    def collections database
      # /databases/<d>/collections
      # GET - lists collections in database <d>
      @url = URI.parse "#{Endpoint}#{database}/collections/#{key}"
    end
   
    def collection database, collection
      # /databases/<d>/collections/<c>
      # GET - lists objects in collection <c>
      # POST - inserts a new object into collection <c>
      @url = URI.parse "#{Endpoint}#{database}/collections/#{collection}#{key}"
    end

    def id database, collection, id, hash={} 
      # /databases/<d>/collections/<c>/<id>
      # GET - returns object with _id <id>
      # PUT - modifies object (or creates if new)
      # DELETE - deletes object with _id <id>
      @url = URI.parse "#{Endpoint}#{database}/collections/#{collection}/id/#{id}#{key}"
    end

    def library_master
      # /databases/<d>/collections/<c>/<id>
      @url = URI.parse "#{Endpoint}/bookmarks/collections/library/master/#{key}"
    end
    
    def select db="bookmarks", coll="library", q={'_id'=>'master'}, *fields
      # /databases/<db>/collections/<coll>
      # ?[q=<query>][&c=true] [&f=<fields>][&fo=true][&s=<order>] [&sk=<skip>][&l=<limit>]
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
      f = {}
      unless fields.empty?
        fields.each {|k| f[k] = 1}
      else
        f['_id'] = 1
      end
      @url = URI.parse(URI.encode "#{Endpoint}#{db}/collections/#{coll}/#{key}&q=#{q.to_json}&f=#{f.to_json}")
    end

    def insert q={}, db="bookmarks", coll="library"
      # /databases/<d>/collections/<c>?[q=<query>][&m=true] [&u=true]
      # PUT - updates one or all objects matching the query.
      #   payload should contain modifier operations
      # q: JSON queryreference
      # m: apply update to all objects in result set
      #  (by default, only one is updated)
      # u: insert if none match the query (upsert)
      @item = q.to_json
      @url = URI.parse(URI.encode "#{Endpoint}#{db}/collections/#{coll}/#{key}")
    end

    def get
      query = Net::HTTP::Get.new(@url.path + '?' + @url.query)
      get_response net.request(query)
    end

    def post hash = nil
      request = Net::HTTP::Post.new(@url.path + '?' + @url.query)
      request.content_type = 'application/json'
      request.body = hash.to_json if hash
      net.start {|http| http.request(request)}.tap do |r|
          puts "#{r.class}:#{r.code}:#{r.message}"
      end
      rescue SocketError
        puts "SocketError rescued"
    end

    def net
      net = Net::HTTP.new(@url.host, @url.port)
      net.use_ssl = true
      @net = net
    end

    def get_response response
      case response
        when Net::HTTPBadResponse
          puts "Net::HTTPBadResponse"
        when Net::HTTPRedirection
          # TODO: manage redirect
        else
          @bookmarks = JSON.parse(response.tap { |r| 
            puts "#{r.class}:#{r.code}:#{r.message}"
            }.body.force_encoding('UTF-8'))
      end
    end

    def dump
      if @bookmarks
        filename = "reading_marks_#{Time.now.strftime("%Y%m%dT%H%M")}"
        io = File.open("#{filename}.json","w")
        JSON.dump(@bookmarks, io)
      else
        raise '@bookmarksEmpty'
      end
    end

    def post_note title, note, url = nil
      hash = {:title => title, :note => note}
      hash[:url] = url if url
      hash[:timestamp] = Time.now
      uri = URI.parse "#{NoteUrl}#{key}"
      net = Net::HTTP.new(uri.host, uri.port)
      net.use_ssl = true
      request = Net::HTTP::Post.new("#{uri.path}?#{uri.query}")
      request.content_type = 'application/json'
      request.body = hash.to_json
      net.start {|http| http.request(request)}.tap do |r|
          puts "#{r.class}:#{r.code}:#{r.message}"
      end
      rescue SocketError
        puts "SocketError rescued"
    end
  end
end

