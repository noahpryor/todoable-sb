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
      let (:auth_hash) { { username: username, password: password } }
      let (:client) { Todoable::Client.new(auth_hash)}

      describe "#authenticate" do

        it "calls the authenticate endpoint" do
          endpoint = "/authenticate"
          options = {basic_auth: auth_hash}

          expect(client.class).to receive(:post)
                                  .with(endpoint, options)
                                  .and_call_original
          client.authenticate
        end

        context "receives a successful response" do

          it "sets the authentication token" do
              client.authenticate
              expect(client.token).to be_a(String)
          end
        end

        context "receives an error from the API" do
          before do
            stub_request(:post, /authenticate/).
            to_return(status: 429)
          end

          it "raises a Todoable::AuthenticationError" do
            expect{ client.authenticate }.to raise_error(Todoable::AuthenticationError)
          end
        end
      end
    end

    context "with an authenticated client" do
      let (:client) { Todoable::Client.build(username: username, password: password) }

      describe "#lists" do

        it "calls the list endpoint" do
          endpoint = "/lists"

          expect(client.class).to receive(:get)
                                  .with(endpoint, Hash)
                                  .and_call_original
          client.lists
        end

        context "and receives a valid response" do
          it "returns an array of Todoable:Lists" do
            lists = client.lists
            expect(lists).to all be_a Todoable::List
          end

          it "sets the name and ID of Todoable::List items" do
            list = client.lists.first
            expect(list.name).to be_a(String)
            expect(list.id).to be_a(String)
          end

        end

        context "and receives an unauthorized response" do
          before do
            stub_request(:get, /lists/).
            to_return(status: 401)
          end

          it "raises a Todoable::Unauthorized error" do
            expect { client.lists }.to raise_error(Todoable::UnauthorizedError)
          end
        end
      end

      describe "#find_list" do
        context "without a list id" do
          it "raises an ArgumentError" do
            expect{ client.find_list() }.to raise_error(ArgumentError)

          end
        end

        context "with a list id" do
          let (:list_id) { "todo-able-list-uuid" }

          it "calls the list endpoint" do
            endpoint = "/lists/#{list_id}"

            expect(client.class).to receive(:get)
                                    .with(endpoint, Hash)
                                    .and_call_original
            client.find_list(list_id)
          end

          context "and receives a valid response" do
            it "returns a single Todoable:List" do
              list = client.find_list(list_id)
              expect(list).to be_a Todoable::List
            end
          end

          context "and receives an unauthorized response" do
            before do
              stub_request(:get, /lists/).
              to_return(status: 401)
            end

            it "raises a Todoable::Unauthorized error" do
              expect { client.lists }.to raise_error(Todoable::UnauthorizedError)
            end
          end


        end
      end

      describe "#create_list" do
        context "without a name" do
          it "raises an ArgumentError" do
            expect{ client.create_list() }.to raise_error(ArgumentError)
          end
        end

        context "with a name " do
          let (:name) { "Urgent Things" }

          it "posts to the list endpoint" do
            endpoint = "/lists"

            expect(client.class).to receive(:post)
                                    .with(endpoint, Hash)
                                    .and_call_original
            client.create_list(name: name)
          end

          context "and receives a valid response" do
            it "returns a single Todoable:List" do
              list = client.create_list(name: name)
              expect(list).to be_a Todoable::List
            end

            it "has the correct list name" do
              list = client.create_list(name: name)
              expect(list.name).to eq(name)
            end

            it "has no items" do
              list = client.create_list(name: name)
              expect(list.items).to eq([])
            end

            # this passes as I'm mocking expected result to return a header,
            # but I'm not seeing the location header from the live API
            it "has an id" do
              list = client.create_list(name: name)
              expect(list.id).to eq('this-is-a-list-id')
            end

          end

          context "and receives an unauthorized response" do
            before do
              stub_request(:post, /lists/).
              to_return(status: 401)
            end

            it "raises a Todoable::Unauthorized error" do
              expect { client.create_list(name: name) }.to raise_error(Todoable::UnauthorizedError)
            end
          end


        end
      end

      describe "#update_list" do
        context "without a name" do
          it "raises an ArgumentError" do
            expect{ client.update_list() }.to raise_error(ArgumentError)
          end
        end

        context "with a name " do
          let (:id) { "todo-able-list-uuid" }
          let (:name) { "Not Reaaly So Urgent Anymore" }

          it "patches to the list endpoint" do
            endpoint = "/lists/#{id}"

            expect(client.class).to receive(:patch)
                                    .with(endpoint, Hash)
                                    .and_call_original
            client.update_list(id: id, name: name)
          end

          context "and receives a valid response" do
            it "returns a single Todoable:List" do
              list = client.update_list(id: id, name: name)
              expect(list).to be_a Todoable::List
            end

            it "has the updated list name" do
              list = client.update_list(id: id, name: name)
              expect(list.name).to eq(name)
            end

            xit "doesn't affect list items" do
              list = client.update_list(id: id, name: name)
              expect(list.items).to eq([])
            end

          end

          context "and receives an unauthorized response" do
            before do
              stub_request(:patch, /lists\//).
              to_return(status: 401)
            end

            it "raises a Todoable::Unauthorized error" do
              expect { client.update_list(id: id, name: name) }.to raise_error(Todoable::UnauthorizedError)
            end
          end


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
