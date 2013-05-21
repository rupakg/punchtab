require 'rubygems'
require 'hashie'
require 'httparty'
require 'json'

#require 'punchtab/auth'


module Punchtab
  class API
    include HTTParty

    BASE_API_URL = 'https://api.punchtab.com/v1'

    base_uri BASE_API_URL
    format :json

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
      response = Hashie::Mash.new(raw_response)
      if response.status == 'connected'
        @access_token = response.authResponse.accessToken
        return response
      else
        if response.error
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
      response = Hashie::Mash.new(raw_response)
      if response.status == 'disconnected'
        return response
      else
        if response.error
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
      response = Hashie::Mash.new(raw_response)
      if response.status == 'connected'
        return response
      else
        if response.error
          raise Exception.new(raw_response)
        end
      end
    end

    ######### Activity APIs

    # Required Parameters
    # access_token - auth token of the user that you get through the authentication flow.
    # Optional Parameters
    # options<~Hash>
    #   * 'limit' - specifies the number of activities.
    #   * 'user_id' - retrieve the activity for a specific user_id, instead of the user currently logged in.
    #   * 'activity_name' - retrieve only a list of activity from the activity_name.
    # Return
    #
    def get_activity(options={})

    end




  end

  class Client

    attr_reader :access_token

    def initialize(options = {})
      # initialize the API
      @api = Punchtab::API.new(options)

      # authenticate
      response = @api.authenticate
      if response
        # get the access token
        @access_token = @api.access_token
      end

    end

    def status
      @api.status
    end

    def logout
      @api.logout
    end

  end
end
