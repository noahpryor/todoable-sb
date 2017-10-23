module Todoable
  class Client

    attr_writer :username, :password

    def initialize(username: , password: )
      @username, @password = username, password
    end

  end
end
