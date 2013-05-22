module Punchtab
  module Utils
    def self.objectify(raw_response)
      if raw_response.body.is_a?(Hash)
         return Hashie::Mash.new(raw_response)
      end
      raw_response
    end
  end
end