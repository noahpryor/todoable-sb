require 'spec_helper'

describe Todoable::Client do
  let (:username) { "username" }
  let (:password) { "password" }

  describe "#new" do

    it "raises an error when initiliazed without a username" do
      expect{ Todoable::Client.new(password: password) }.to raise_error(ArgumentError)
    end

    it "raises an error when initiliazed without a password" do
      expect{ Todoable::Client.new(username: username) }.to raise_error(ArgumentError)
    end

    it "initializes a client with username and password" do
      client = Todoable::Client.new(username: username, password: password)
      expect(client).to be_a Todoable::Client
    end
  end

end
