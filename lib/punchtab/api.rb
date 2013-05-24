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
      response = Punchtab::Utils.process_response(raw_response)
      # return the access token
      @access_token = response.authResponse.accessToken
    end

    # Required Parameters
    #   None
    # Optional Parameters
    #   None
    # Return
    #  https://api.punchtab.com/v1/auth/logout
    def logout
      # make the POST call
      path = '/auth/logout'

      # setup the post params
      post_data = {
        :token  => @access_token,
        :key    => @access_key
      }
      raw_response = Punchtab::API.post(path, :body => post_data)
      Punchtab::Utils.process_response(raw_response)
    end

    # Required Parameters
    #   None
    # Optional Parameters
    #   None
    # Return
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
      Punchtab::Utils.process_response(raw_response)
    end

    ######### Activity APIs

    # Required Parameters
    #   None
    # Optional Parameters
    #   options<~Hash>
    #     * 'activity_name'<~String> - retrieve only a list of activities for the activity.
    #     * 'limit'<~Integer> - limits the number of activities.
    #     * 'user_id'<~Integer> - retrieve the activity for a specific user_id, instead of the user currently logged in.
    # Return
    # https://api.punchtab.com/v1/activity/[activity_name]?access_token=<access_token>
    def get_activity(options={})
      activity_name = options.delete(:activity_name)
      unless activity_name.nil? || activity_valid?(activity_name)
        puts "Specify an activity from the list: '#{activity_list}'"
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
      Punchtab::Utils.process_response(raw_response)
    end

    # Required Parameters
    #   * 'activity_name'<~String> - retrieve only a list of activity from the activity_name.
    #   * 'points'<~Integer> - points for the activity, default is 100
    # Optional Parameters
    #   None
    # Return
    # curl i -X POST 'points=200' https://api.punchtab.com/v1/activity/<activity_name>?access_token=<access_token>
    def create_activity(activity_name, points=100)
      unless activity_valid?(activity_name)
        puts "Specify an activity from the list: '#{activity_list}'"
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
      Punchtab::Utils.process_response(raw_response)
    end

    # Required Parameters
    #   * 'reward_id'<~Integer> - reward id for the activity offer to redeem
    # Optional Parameters
    #   None
    # Return
    # curl i -X POST 'reward_id=123' https://api.punchtab.com/v1/activity/redeem?access_token=<access_token>
    def redeem_activity_offer(reward_id)

      # make the POST call
      path = '/activity/redeem'

      options = {:access_token => @access_token}
      raw_response = Punchtab::API.post(path, {:body => "reward_id=#{reward_id}", :query => options })
      Punchtab::Utils.process_response(raw_response)
    end

  ######### User APIs

    # Required Parameters
    #   None
    # Optional Parameters
    #   None
    # Return
    # https://api.punchtab.com/v1/user?access_token=<access_token>
    def get_user
      # make the GET call
      path = '/user'

      options = {:access_token => @access_token}
      raw_response = Punchtab::API.get(path, :query => options)
      Punchtab::Utils.process_response(raw_response)
    end

  ######### Reward APIs

    # Required Parameters
    #   None
    # Optional Parameters
    #   options<~Hash>
    #     * 'limit'<~Integer> - limits the number of rewards.
    # Return
    # https://api.punchtab.com/v1/reward?access_token=<access_token>
    def get_reward(options={})
      # make the GET call
      path = '/reward'

      options.merge!({:access_token => @access_token})
      raw_response = Punchtab::API.get(path, :query => options)
      Punchtab::Utils.process_response(raw_response)
    end

  ######### Leaderboard APIs

    # Required Parameters
    #   None
    # Optional Parameters
    #   options<~Hash>
    #     * 'with'<~String> - User Id or 'me'. Defaults to 'me', which will get a leaderboard with the current user.
    #     * 'days'<~String> - if set to 'all' returns the leaderboard from the beginning using redeemable points, otherwise it returns the leaderboard from the last 30 days.
    #     * 'limit'<~Integer> - limits the number of users in the leaderboard.
    #     * 'page'<~Integer> - specifies the page of result you want (rank will be relative to the page).
    # Return
    # https://api.punchtab.com/v1/leaderboard?access_token=<access_token>
    def get_leaderboard(options={})
      # make the GET call
      path = '/leaderboard'

      options.merge!({:with => 'me', :access_token => @access_token})
      raw_response = Punchtab::API.get(path, :query => options)
      Punchtab::Utils.process_response(raw_response)
    end


    private

    def activity_valid?(activity_name)
      ACTIVITIES.include?(activity_name.to_s)
    end

    def activity_list
      ACTIVITIES.join(',')
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