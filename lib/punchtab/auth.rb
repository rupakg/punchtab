#module Punchtab
#  class Auth
#    include HTTParty
#
#    base_uri BASE_API_URL
#    format :json
#
#    def self.authenticate(options = {})
#      @client_id    = options[:client_id]     # required
#      @access_key   = options[:access_key]    # required
#      @secret_key   = options[:secret_key]    # required
#
#      if @client_id && @access_key && @secret_key
#        user_data = [
#            'id'          => @client_id,
#            'first_name'  => 'Rupak',
#            'last_name'   => 'Ganguly',
#            'email'       => 'rupakg@gmail.com'
#        ]
#        time_stamp = Time.now.to_i
#        auth_request = Base64.encode64(JSON.dump(user_data))
#        string_to_sign = "#{auth_request} #{time_stamp}"
#        hmac = OpenSSL::HMAC.new(@secret_key, OpenSSL::Digest::SHA1.new)
#        signature = hmac.update(string_to_sign).hexdigest
#
#        # make the POST call
#        path = '/auth/sso'
#        post_data = {
#            :client_id    => @client_id,
#            :key          => @access_key,
#            :auth_request => auth_request,
#            :timestamp    => time_stamp,
#            :signature    => signature
#        }
#        response = Hashie::Mash.new(Punchtab::Auth.post(path, :body => post_data))
#        if response.status == 'connected'
#          response.authResponse.accessToken
#        else
#          if response.error
#            raise Exception.new("Authentication Failed: '#{response.error.description}', Status: '#{response.status}'")
#          end
#        end
#      else
#        raise ArgumentError.new('Client Id, Access Key and Secret Key are required to authenticate, before using PunchTab services.')
#      end
#    end
#
#  end
#end
