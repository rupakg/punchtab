module Punchtab

  module Utils

    def self.process_response(raw_response)
      if (500..599).include?(raw_response.code)
        raise Exception.new("#{raw_response.code} Server Error")
      elsif raw_response.code == 400
        raise Exception.new("#{raw_response.code} Bad Request")
      elsif (200..208).include?(raw_response.code) || raw_response.code == 226
        begin
          response = Hashie::Mash.new(raw_response)
        rescue
          return raw_response
        end
        begin
          if response.error
            raise Exception.new(raw_response)
          else
            return response
          end
        rescue
          raise Exception.new(raw_response)
        end
      end
    end
  end
end