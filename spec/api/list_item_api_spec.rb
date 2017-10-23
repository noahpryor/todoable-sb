require 'spec_helper'

describe Todoable::Api::ListItem do
  context "with an authenticated client" do
    let (:username) { "username" }
    let (:password) { "password" }
    let (:client) { Todoable::Client.build(username: username, password: password) }

    describe "#add_item" do
      let (:id) { "todo-able-list-uuid" }
      let (:name) { "Urgent Things" }

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
        Todoable::List.build_from_response(id: id, name: name, items: items)
      }

      let (:new_item) { Todoable::ListItem.new(name: 'third') }

      context "without a list" do
        it "raises an ArgumentError" do
          expect{ client.add_item(item: new_item) }.to raise_error(ArgumentError)
        end
      end

      context "without an item" do
        it "raises an ArgumentError" do
          expect{ client.add_item(list: list) }.to raise_error(ArgumentError)
        end
      end

      context "with a new item and list" do

        it "puts to the list items endpoint" do
          endpoint = "/lists/#{id}/items"

          expect(client.class).to receive(:post)
                                  .with(endpoint, Hash)
                                  .and_call_original
          client.add_item(list: list, item: new_item)
        end

        context "and receives a valid response" do
          it "returns a single Todoable:List" do
            updated_list = client.add_item(list: list, item: new_item)
            expect(updated_list).to be_a Todoable::List
          end

          it "has the same list name" do
            updated_list = client.add_item(list: list, item: new_item)
            expect(updated_list.name).to eq(name)
          end

          it "adds the new list item" do
            item_count = items.count
            updated_list = client.add_item(list: list, item: new_item)
            expect(updated_list.items.count).to eq(item_count + 1)
            expect(updated_list.items.last).to eq(new_item)
          end
        end

        context "and receives an unauthorized response" do
          before do
            stub_request(:post, /lists\//).
            to_return(status: 401)
          end

          it "raises a Todoable::Unauthorized error" do
            expect { client.add_item(list: list, item: new_item) }.to raise_error(Todoable::UnauthorizedError)
          end
        end
      end
    end

    describe "#finish_item" do
      context "with a not yet persisted item" do
        let (:item) { Todoable::ListItem.new(name: "Save this todo") }
        it "raises an ArgumentError" do
          expect{ client.finish_item(item: item) }.to raise_error(ArgumentError)
        end
      end

      context "with a persisted item belonging to a list" do
        let (:id) { "todo-able-list-item-uuid"}
        let (:list_id) { "todo-able-list-uuid"}
        let (:item) {
          Todoable::ListItem.build_from_response(
            id: id, list_id: list_id, name: 'first', status: :todo
          )
        }

        it "puts to the list items finish endpoint" do
          endpoint = "/lists/#{list_id}/items/#{id}/finish"

          expect(client.class).to receive(:put)
                                  .with(endpoint, Hash)
                                  .and_call_original
          client.finish_item(item: item)
        end

        context "and receives a valid response" do
          it "returns the Todoable::ListItem" do
            finished_item = client.finish_item(item: item)
            expect(finished_item).to be_a Todoable::ListItem
          end

          it "shows the item as finished" do
            finished_item = client.finish_item(item: item)
            expect(finished_item.status).to eq(:done)
          end
        end

        context "and receives an unauthorized response" do
          before do
            stub_request(:put, /lists\//).
            to_return(status: 401)
          end

          it "raises a Todoable::Unauthorized error" do
            expect { client.finish_item(item: item) }.to raise_error(Todoable::UnauthorizedError)
          end
        end
      end
    end

    describe "#delete_item" do
      context "with a not yet persisted item" do
        let (:item) { Todoable::ListItem.new(name: "Save this todo") }
        it "raises an ArgumentError" do
          expect{ client.delete_item(item: item) }.to raise_error(ArgumentError)
        end
      end

      context "with a persisted item belonging to a list" do
        let (:id) { "todo-able-list-item-uuid"}
        let (:list_id) { "todo-able-list-uuid"}
        let (:item) {
          Todoable::ListItem.build_from_response(
            id: id, list_id: list_id, name: 'first', status: :todo
          )
        }

        it "deleted to the delete items endpoint" do
          endpoint = "/lists/#{list_id}/items/#{id}"

          expect(client.class).to receive(:delete)
                                  .with(endpoint, Hash)
                                  .and_call_original
          client.delete_item(item: item)
        end

        context "and receives a valid response" do
          it "returns true" do # NOTE: is this the best thing to do here?
            result = client.delete_item(item: item)
            expect(result).to eq(true)
          end
        end

        context "and receives an unauthorized response" do
          before do
            stub_request(:delete, /lists\//).
            to_return(status: 401)
          end

          it "raises a Todoable::Unauthorized error" do
            expect { client.delete_item(item: item) }.to raise_error(Todoable::UnauthorizedError)
          end
        end
      end
    end
  end
end
