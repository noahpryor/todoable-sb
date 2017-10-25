# frozen_string_literal: true

require 'spec_helper'

describe Todoable::Api::ListItem do
  context 'with an unauthenticated client' do
    let(:username) { 'username' }
    let(:password) { 'password' }
    let(:client) do
      Todoable::Client.new(username: username, password: password)
    end

    describe '#create_item' do
      let(:list_id) { 'todo-able-list-uuid' }
      let(:name) { 'Urgent Things' }

      it 'raises a Todoable::NotAuthenticated error' do
        expect { client.create_item(list_id: list_id, name: name) }
          .to raise_error(Todoable::NotAuthenticated)
      end
    end

    describe '#finish_item' do
      let(:list_id) { 'todo-able-list-uuid' }
      let(:id) { 'todo-able-list-item-uuid' }

      it 'raises a Todoable::NotAuthenticated error' do
        expect { client.finish_item(list_id: list_id, id: id) }
          .to raise_error(Todoable::NotAuthenticated)
      end
    end

    describe '#delete_item' do
      let(:list_id) { 'todo-able-list-uuid' }
      let(:id) { 'todo-able-list-item-uuid' }

      it 'raises a Todoable::NotAuthenticated error' do
        expect { client.delete_item(list_id: list_id, id: id) }
          .to raise_error(Todoable::NotAuthenticated)
      end
    end
  end

  context 'with an authenticated client' do
    let(:username) { 'username' }
    let(:password) { 'password' }
    let(:client) do
      Todoable::Client.build(username: username, password: password)
    end

    describe '#create_item' do
      let(:list_id) { 'todo-able-list-uuid' }
      let(:name) { 'Urgent Things' }
      let(:endpoint) { "/lists/#{list_id}/items" }

      it 'without a list_id raises an ArgumentError' do
        expect { client.create_item(name: name) }
          .to raise_error(ArgumentError)
      end

      it 'without a name raises an ArgumentError' do
        expect { client.create_item(list_id: list_id) }
          .to raise_error(ArgumentError)
      end

      it 'with an invalid list_id raises a ContentNotFoundError' do
        stub_request(:post, /lists/)
          .to_return(status: 404)
        expect do
          client.create_item(list_id: list_id, name: name)
        end.to raise_error(Todoable::ContentNotFoundError)
      end

      it 'posts to the list items endpoint with a list id' do
        allow(client.class).to receive(:post)
          .and_call_original
        client.create_item(list_id: list_id, name: name)
        expect(client.class).to have_received(:post)
          .with(endpoint, Hash)
      end

      it 'returns a single Todoable::ListItem' do
        new_item = client.create_item(list_id: list_id, name: name)
        expect(new_item.is_a?(Todoable::ListItem)).to be(true)
      end

      it 'has the expected name' do
        new_item = client.create_item(list_id: list_id, name: name)
        expect(new_item.name).to eq(name)
      end

      it 'has the expected list_id' do
        new_item = client.create_item(list_id: list_id, name: name)
        expect(new_item.list_id).to eq(list_id)
      end
    end

    describe '#finish_item' do
      let(:id) { 'todo-able-list-item-uuid' }
      let(:list_id) { 'todo-able-list-uuid' }
      let(:endpoint) { "/lists/#{list_id}/items/#{id}/finish" }

      it 'without a list id raises an ArgumentError' do
        expect { client.finish_item(id: id) }.to raise_error(ArgumentError)
      end

      it 'without a id raises an ArgumentError' do
        expect { client.finish_item(list_id: list_id) }
          .to raise_error(ArgumentError)
      end

      it 'with an invalid id raises a ContentNotFoundError' do
        stub_request(:put, /lists/).to_return(status: 404)
        expect do
          client.finish_item(id: id, list_id: list_id)
        end.to raise_error(Todoable::ContentNotFoundError)
      end

      it 'puts to the list items finish endpoint with an id' do
        allow(client.class).to receive(:put)
          .and_call_original
        client.finish_item(id: id, list_id: list_id)
        expect(client.class).to have_received(:put)
          .with(endpoint, Hash)
      end

      it 'returns true' do
        result = client.finish_item(id: id, list_id: list_id)
        expect(result).to eq(true)
      end
    end

    describe '#delete_item' do
      let(:id) { 'todo-able-list-item-uuid' }
      let(:list_id) { 'todo-able-list-uuid' }
      let(:endpoint) { "/lists/#{list_id}/items/#{id}" }

      it 'without a list id raises an ArgumentError' do
        expect { client.delete_item(id: id) }.to raise_error(ArgumentError)
      end

      it 'without an item id raises an ArgumentError' do
        expect { client.delete_item(list_id: list_id) }
          .to raise_error(ArgumentError)
      end

      it 'with an invalid list id raises a ContentNotFoundError' do
        stub_request(:delete, /lists/)
          .to_return(status: 404)
        expect { client.delete_item(id: id, list_id: list_id) }
          .to raise_error(Todoable::ContentNotFoundError)
      end

      it 'puts to the list items finish endpoint' do
        allow(client.class).to receive(:delete)
          .and_call_original
        client.delete_item(id: id, list_id: list_id)
        expect(client.class).to have_received(:delete)
          .with(endpoint, Hash)
      end

      it 'returns true' do
        result = client.delete_item(id: id, list_id: list_id)
        expect(result).to eq(true)
      end
    end
  end
end
