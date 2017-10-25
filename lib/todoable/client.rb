# frozen_string_literal: true

require 'httparty'

module Todoable
  # Base class for calling Todoable API
  # @attr [String] token The authentication token Todoable returned
  #   in exchange for username and password. Used to authenticate all
  #   requests.
  class Client
    include Api::List
    include Api::ListItem
    include HTTParty
    format :json
    base_uri 'https://todoable.teachable.tech/api'

    attr_reader :token, :token_expiry

    # Create a client with a username and password
    #
    # @param username [String] the username from Todoable
    # @param password [String] the password from Todoable
    # @return [Todoable::Client] An unauthenticated client
    #
    # @example
    #   Todoable::Client.new(username: "foo", password: "bar") =>
    #     <Todoable::Client
    #       @token=nil,
    #       @options={},
    #       @username="foo"
    #       @password="bar"
    #     >
    def initialize(username:, password:)
      @username = username
      @password = password
      @options = {}
    end

    # Authenticate an initialized client by making a call to exchange the
    # username and password for a token. Sets the token for future calls from
    # the client
    #
    # @return [Todoable::Client] an authenticated client
    #
    # @example
    #
    #   client = Todoable::Client.new(username: "foo", password: "bar")
    #   client.authenticate =>
    #     <Todoable::Client @token="a-valid-token">

    def authenticate
      @options[:basic_auth] = {
        username: @username,
        password: @password
      }
      response = self.class.post('/authenticate', @options)
      check_and_raise_errors(response)
      @token = response.parsed_response['token']
      # tokens expire after 20 minutes
      @token_expiry = Time.now + (20 * 60)
      self
    end

    # Convenience initializer to create an authenticated client
    # username and password for a token. Sets the token for future calls from
    # the client
    #
    # @param username [String] the username from Todoable
    # @param password [String] the password from Todoable
    #
    # @return [Todoable::Client] An unauthenticated client
    #
    #
    # @example
    #   client = Todoable::Client.build(username: "foo", password: "bar") =>
    #     <Todoable::Client @token="a-valid-token">

    def self.build(username:, password:)
      new(username: username, password: password).authenticate
    end

    private

    attr_writer :username, :password, :options, :token_expiry

    def token_expired
      Time.now > @token_expiry
    end

    # Called before attempting to access Todoable API, will refresh
    #   token if expired and continue with call
    def check_token
      raise NotAuthenticated unless @token
      authenticate if token_expired
    end

    def check_and_raise_errors(response)
      case response.code.to_i
      when 200..300
        return true
      when 404
        raise ContentNotFoundError
      when 401
        raise UnauthorizedError
      when 422
        
        raise UnprocessableError
      else
        raise StandardError.new(
          "Uknown error. Status code #{respon.code} from Todoable API"
        )
      end
    end

    def headers
      { 'Authorization': "Token token=#{@token}" }
    end
  end

  class ContentNotFoundError < StandardError
    # Raised when
  end

  class UnprocessableError < StandardError
  end

  class NotAuthenticated < StandardError
  end

end
