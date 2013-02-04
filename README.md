# Mongoleaf

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'mongoleaf'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongoleaf

## Usage

TODO: Write usage instructions here

```ruby
require 'mongoleaf'
include Mongoleaf
Mongoleaf.insert({:title => 'foo', :content => 'foobar'}, 'db', 'notes')
```

```ruby
require 'mongoleaf'
include Mongoleaf
Mongoleaf.insert_to_mongo({:title => 'yup', :content => 'yup note from irb'})
```

```
"2013-02-03 14:19:40 +0100 Mongoleaf::Poster included"
"2013-02-03 14:19:40 +0100 Mongoleaf::Util included"
{"_id"=>BSON::ObjectId('510e63ecd508fe1fde000001'), "title"=>"yup", "content"=>"yup note from irb", "timestamp"=>2013-02-03 13:19:40 UTC}
```

...

```ruby
def key k = nil
private :key
def databases
def databases_subservices database
def collections database
def collection database, collection
def id database, collection, id, hash={} 
def library_master
def select db="bookmarks", coll="library", q={'_id'=>'master'}, *fields
def insert q={}, db="bookmarks", coll="library"
def get
def post hash = nil
def net
def get_response response
def dump
def post_note title, note, url = nil
```

## API

```ruby
    def connect db_name = 'bookmarks'
    def collection_names database = 'bookmarks'
    def insert_to_mongo item
    def insert_item item, collection_name = 'notes', database = 'bookmarks'
    def update_item id, item, collection_name = 'notes', database = 'bookmarks'
    def update_item_and_value id, key, value, collection_name = 'notes', database = 'bookmarks'
    def find_all collection_name = 'notes', database = 'bookmarks'
    def find_by_id id, collection_name = 'notes', database = 'bookmarks'
    def remove_by_id id, collection_name = 'notes', database = 'bookmarks' 
    def count_collection collection_name = 'notes', database = 'bookmarks'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
