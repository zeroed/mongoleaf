
module Mongoleaf::Util
  def self.included(klass)
    klass.extend MongoleafUtil::ClassMethods
  end
  module ClassMethods
  end
end
