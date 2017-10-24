require 'spec_helper'

describe Todoable::Api::List do

  context "with an authenticated client" do
    let (:username) { "username" }
    let (:password) { "password" }
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
      let (:list_id) { "todo-able-list-uuid"}
      let (:name) { "New List" }

      context "without a list_id" do
        it "raises an ArgumentError" do
          expect{client.create_list(name: name)}.to raise_error(ArgumentError)
        end
      end

      context "without a name" do
        it "raises an ArgumentError" do
          expect{ client.create_list(list_id: list_id) }.to raise_error(ArgumentError)
        end
      end

      context "with an invalid list_id" do

        before do
          stub_request(:post, /lists/).
          to_return(status: 404)
        end

        it "raises a ContentNotFoundError error" do
          expect{ client.create_list(
            list_id: list_id, name: name
          )}.to raise_error(Todoable::ContentNotFoundError)
        end

      end

      context "with a valid list_id and name" do
        let (:list) { Todoable::List.new(name: name) }

        it "calls #save_list with a Todoable::List" do
          allow(Todoable::List).to receive(:new).and_return(list)
          expected_list_arg = { list:  list }
          expect(client).to receive(:save_list).with(expected_list_arg)
                                               .and_call_original
          client.create_list(list_id: list_id, name: name)
        end
      end
    end

    describe "#save_list" do
      context "without a list" do
        it "raises an ArgumentError" do
          expect{ client.save_list() }.to raise_error(ArgumentError)
        end
      end

      context "with a Todoable::List " do
        let (:name) { "Urgent Things" }
        let (:list) { Todoable::List.new(name: name) }

        it "posts to the list endpoint" do
          endpoint = "/lists"
          expect(client.class).to receive(:post)
                                  .with(endpoint, Hash)
                                  .and_call_original
          client.save_list(list: list)
        end

        context "and receives a valid response" do
          it "returns a single Todoable:List" do
            persisted_list = client.save_list(list: list)
            expect(persisted_list).to be_a Todoable::List
          end

          it "has the correct list name" do
            persisted_list = client.save_list(list: list)
            expect(persisted_list.name).to eq(name)
          end

          it "has no items" do
            persisted_list = client.save_list(list: list)
            expect(persisted_list.items).to eq([])
          end

          # this passes as I'm mocking expected result to return a header,
          # but I'm not seeing the location header from the live API
          it "has an id" do
            persisted_list = client.save_list(list: list)
            expect(persisted_list.id).to eq('this-is-a-list-id')
          end

        end

        context "and receives an unauthorized response" do
          before do
            stub_request(:post, /lists/).
            to_return(status: 401)
          end

          it "raises a Todoable::Unauthorized error" do
            expect { client.save_list(list: list) }.to raise_error(Todoable::UnauthorizedError)
          end
        end


      end
    end

    describe "#update" do
      context "without a list" do
        it "raises an ArgumentError" do
          expect{ client.update() }.to raise_error(ArgumentError)
        end
      end

      context "with a new name " do
        let (:id) { "todo-able-list-uuid" }
        let (:name) { "Not Really So Urgent Anymore" }
        let (:items) { [
            Todoable::ListItem.build_from_response(
              id: 'id1', list_id: id, name: 'first', status: :todo
            ),
            Todoable::ListItem.build_from_response(
              id: 'id2', list_id: id, name: 'second', status: :todo
            ),
          ]
        }
        let (:list) {
          Todoable::List.build_from_response(id: id, name: "Urgent Things", items: items)
        }

        it "patches to the list endpoint" do
          endpoint = "/lists/#{id}"

          expect(client.class).to receive(:patch)
                                  .with(endpoint, Hash)
                                  .and_call_original
          client.update(list: list, name: name)
        end

        context "and receives a valid response" do
          it "returns a single Todoable:List" do
            updated_list = client.update(list: list, name: name)
            expect(updated_list).to be_a Todoable::List
          end

          it "has the updated list name" do
            updated_list = client.update(list: list, name: name)
            expect(updated_list.name).to eq(name)
          end

          it "doesn't affect list items" do
            updated_list = client.update(list: list, name: name)
            expect(updated_list.items).to eq(items)
          end
        end

        context "and receives an unauthorized response" do
          before do
            stub_request(:patch, /lists\//).
            to_return(status: 401)
          end

          it "raises a Todoable::Unauthorized error" do
            expect { client.update(list: list, name: name) }.to raise_error(Todoable::UnauthorizedError)
          end
        end
      end
    end

    describe "#delete_list" do
      context "without a list" do
        it "raises an ArgumentError" do
          expect{ client.delete_list() }.to raise_error(ArgumentError)
        end
      end

      context "without a non-persisted list" do
        let (:list) { Todoable::List.new(name: "Save Me Plz") }
        it "raises an ArgumentError" do
          expect{ client.delete_list(list: list)}.to raise_error(ArgumentError)
        end
      end

      context "with a persisted list" do
        let (:id) { "todo-able-list-uuid" }
        let (:name) { "Not Really So Urgent Anymore" }
        let (:items) { [
            Todoable::ListItem.build_from_response(
              id: 'id1', list_id: id, name: 'first', status: :todo
            ),
            Todoable::ListItem.build_from_response(
              id: 'id2', list_id: id, name: 'second', status: :todo
            ),
          ]
        }
        let (:list) {
          Todoable::List.build_from_response(id: id, name: "Urgent Things", items: items)
        }

        it "deletes to the list endpoint" do
          endpoint = "/lists/#{id}"
          expect(client.class).to receive(:delete)
                                  .with(endpoint, Hash)
                                  .and_call_original
          client.delete_list(list: list)
        end

        context "and receives a valid response" do
          it "returns true" do
            response = client.delete_list(list: list)
            expect(response).to eq(true)
          end
        end

        context "and receives an unauthorized response" do
          before do
            stub_request(:delete, /lists\//).
            to_return(status: 401)
          end

          it "raises a Todoable::Unauthorized error" do
            expect { client.delete_list(list: list) }.to raise_error(Todoable::UnauthorizedError)
          end
        end
      end
    end

  end
end
