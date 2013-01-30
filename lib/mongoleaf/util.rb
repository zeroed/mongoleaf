
module Mongoleaf::Util
  def self.included(klass)
    klass.extend self::ClassMethods
  end
  module ClassMethods
  end
end
