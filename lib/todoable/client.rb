module Todoable
  class Client

    attr_accessor :token
    attr_writer :username, :password

    # TODO: document this
    def initialize(username: , password: )
      @username, @password = username, password
    end

    # TODO: document this
    def authenticate
      # TODO: implement calling the API
      @token = 'this-should-be-a-real-token'
    end

    # TODO: document this
    def self.build(username: , password: )
      new(username: username, password: password).authenticate
    end

  end
end
