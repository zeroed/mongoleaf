require "mongoleaf/version"
require "mongoleaf/poster"
require "mongoleaf/util"

module Mongoleaf
  include Poster
  include Util
  def self.included(klass)
    # p "#{Time.now} #{self} included"
    # klass.extend(self)
  end
end
