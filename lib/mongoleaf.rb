
module Mongoleaf
  def self.included(klass)
    require "mongoleaf/version"
    require "mongoleaf/poster"
    require "mongoleaf/util"
    include Poster
    include Util
  end
end
