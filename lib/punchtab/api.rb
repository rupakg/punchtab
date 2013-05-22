require 'httparty'
require 'json'

module Punchtab

  class API
    include HTTParty
    include Utils

    BASE_API_URL  = 'https://api.punchtab.com/v1'
    ACTIVITIES    = %w(visit tweet like plusone comment invite reply apply share purchase addtotimeline search download view checkin subscribe follow)

    base_uri BASE_API_URL
    format :json
    # enable debug mode
    if ENV['PUNCHTAB_DEBUG'] == '1'
      debug_output
    end

    attr_reader :access_token

    def initialize(options = {})
      @client_id    = options[:client_id]     # required
      @access_key   = options[:access_key]    # required
      @secret_key   = options[:secret_key]    # required
      @domain       = options[:domain]        # required
      @user_info    = options[:user_info]     # optional

      Punchtab::API.headers 'Referer' => "http://#{@domain}"

      unless @client_id && @access_key && @secret_key && @domain
        raise Exception.new('Client Id, Access Key, Secret Key and Domain are required to authenticate, before using PunchTab services.')
      end
    end

    ######### Authentication APIs

    # https://api.punchtab.com/v1/auth/sso
    def authenticate
      # setup the user data structure
      user_data = {:id => @client_id}
      if @user_info
        user_data.merge!(@user_info)
      end

      # prepare authentication params
      time_stamp = Time.now.to_i
      auth_request = Base64.encode64(JSON.dump(user_data))
      string_to_sign = "#{auth_request} #{time_stamp}"
      hmac = OpenSSL::HMAC.new(@secret_key, OpenSSL::Digest::SHA1.new)
      signature = hmac.update(string_to_sign).hexdigest

      # make the POST call
      path = '/auth/sso'

      # setup the post params
      post_data = {
          :client_id    => @client_id,
          :key          => @access_key,
          :auth_request => auth_request,
          :timestamp    => time_stamp,
          :signature    => signature
      }
      raw_response = Punchtab::API.post(path, :body => post_data)
      if raw_response.code == 200
        response = Hashie::Mash.new(raw_response)
        if response.status == 'connected'
          @access_token = response.authResponse.accessToken
          return response
        else
          if response.error
            raise Exception.new(response)
          end
        end
      else
        if raw_response.message
          raise Exception.new(raw_response)
        end
      end
    end

    # https://api.punchtab.com/v1/auth/logout
    def logout
      # make the POST call
      path = '/auth/logout'

      # setup the post params
      post_data = {
        :token  => @access_token,
        :key    => @access_key
      }
      raw_response = Punchtab::API.post(path, :body => post_data)
      if raw_response.code == 200
        response = Hashie::Mash.new(raw_response)
        if response.status == 'disconnected'
          return response
        else
          if response.error
            raise Exception.new(response)
          end
        end
      else
        if raw_response.message
          raise Exception.new(raw_response)
        end
      end

    end

    # https://api.punchtab.com/v1/auth/status
    def status
      # make the POST call
      path = '/auth/status'

      # setup the post params
      post_data = {
          :token  => @access_token,
          :key    => @access_key
      }
      raw_response = Punchtab::API.post(path, :body => post_data)
      if raw_response.code == 200
        response = Hashie::Mash.new(raw_response)
        if response.status == 'connected'
          return response
        else
          if response.error
            raise Exception.new(response)
          end
        end
      else
        if raw_response.message
          raise Exception.new(raw_response)
        end
      end
    end

    ######### Activity APIs

    # Required Parameters
    #   * 'access_token' - auth token of the user that you get through the authentication flow.
    # Optional Parameters
    #   options<~Hash>
    #     * 'activity_name' - retrieve only a list of activities for the activity.
    #     * 'limit' - specifies the number of activities.
    #     * 'user_id' - retrieve the activity for a specific user_id, instead of the user currently logged in.
    # Return
    # https://api.punchtab.com/v1/activity/[activity_name]?access_token=<access_token>
    def get_activity(options={})
      activity_name = options.delete(:activity_name)
      unless activity_name.nil? || ACTIVITIES.include?(activity_name.to_s)
        puts "Specify an activity from the list: '#{ACTIVITIES.join(',')}'"
        return
      end
      # make the GET call
      if activity_name
        path = "/activity/#{activity_name}"
      else
        path = '/activity'
      end

      options.merge!({:access_token => @access_token})
      raw_response = Punchtab::API.get(path, :query => options)
      if raw_response.code == 200
        response = Punchtab::Utils.objectify(raw_response)
      else
        if raw_response.message
          raise Exception.new(raw_response)
        end
      end
    end

    # Required Parameters
    #   * 'access_token' - auth token of the user that you get through the authentication flow.
    #   * 'activity_name' - retrieve only a list of activity from the activity_name.
    #   * 'points'<~Integer> - points for the activity, default is 100
    # Return
    # curl i -X POST 'points=200' https://api.punchtab.com/v1/activity/<activity_name>?access_token=<access_token>
    def create_activity(activity_name, points=100)
      unless ACTIVITIES.include?(activity_name.to_s)
        puts "Specify an activity from the list: '#{ACTIVITIES.join(',')}'"
        return
      end
      # make the POST call
      if activity_name
        path = "/activity/#{activity_name}"
      else
        path = '/activity'
      end

      options = {:access_token => @access_token}
      raw_response = Punchtab::API.post(path, {:body => "points=#{points}", :query => options})
      if raw_response.code == 200
        response = Punchtab::Utils.objectify(raw_response)
      else
        if raw_response.message
          raise Exception.new(raw_response)
        end
      end
    end

    # Required Parameters
    #   * 'access_token' - auth token of the user that you get through the authentication flow.
    #   * 'reward_id'<~Integer> - reward id for the activity offer to redeem
    # Return
    # curl i -X POST 'reward_id=123' https://api.punchtab.com/v1/activity/redeem?access_token=<access_token>
    def redeem_activity_offer(reward_id)

      # make the POST call
      path = '/activity/redeem'

      options = {:access_token => @access_token}
      raw_response = Punchtab::API.post(path, {:body => "reward_id=#{reward_id}", :query => options })
      if raw_response.code == 200
        response = Punchtab::Utils.objectify(raw_response)
      else
        if raw_response.message
          raise Exception.new(raw_response)
        end
      end
    end
  end

end

### Hack monkey-patch to rescue parsing errors
module HTTParty
  class Request

    private
    def parse_response(body)
      begin
        parser.call(body, format)
      rescue Exception
        body
      end
    end

  end
end