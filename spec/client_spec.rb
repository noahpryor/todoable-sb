require 'spec_helper'

describe Todoable::Client do
  let (:username) { "username" }
  let (:password) { "password" }

  describe "::new" do

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

    context "with an initialized client" do

      let (:client) { Todoable::Client.new(username: username, password: password)}

      describe "#authenticate" do

        xit "calls the authenticate endpoint" do

        end

        context "receives a successful response" do

          it "sets the authentication token" do
              client.authenticate
              expect(client.token).to be_a(String)
          end
        end

        context "receives an error" do

        end
      end



    end

    describe "::build" do

      let (:client){ Todoable::Client.new(username: username, password: password) }

      it "raises an error when called without a username" do
        expect{ Todoable::Client.build(password: password) }.to raise_error(ArgumentError)
      end

      it "raises an error when called without a password" do
        expect{ Todoable::Client.build(username: username) }.to raise_error(ArgumentError)
      end

      it "initializes and authenticates a client with username and password" do
        expect(Todoable::Client).to receive(:new).with({username: username, password: password})
                                                 .and_return(client)
        expect(client).to receive(:authenticate).once
        Todoable::Client.build(username: username, password: password)
      end


    end

  end

end
