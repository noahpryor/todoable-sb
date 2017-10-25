# frozen_string_literal: true

require 'spec_helper'

describe Todoable::Api::List do
  context 'with an unauthenticated client' do
    let(:username) { 'username' }
    let(:password) { 'password' }
    let(:client) do
      Todoable::Client.new(username: username, password: password)
    end

    describe '#lists' do
      it 'raises a Todoable::NotAuthenticated error' do
        expect { client.lists }.to raise_error(Todoable::NotAuthenticated)
      end
    end

    describe '#find_list' do
      let(:list_id) { 'todo-able-list-uuid' }

      it 'raises a Todoable::NotAuthenticated error' do
        expect { client.find_list(list_id) }
          .to raise_error(Todoable::NotAuthenticated)
      end
    end

    describe '#create_list' do
      let(:name) { 'New List' }

      it 'raises a Todoable::NotAuthenticated error' do
        expect { client.create_list(name: name) }
          .to raise_error(Todoable::NotAuthenticated)
      end
    end

    describe '#update_list' do
      let(:id) { 'todo-able-list-uuid' }
      let(:name) { 'Not Really So Urgent Anymore' }

      it 'raises a Todoable::NotAuthenticated error' do
        expect do
          client.update_list(list_id: id, name: name)
        end.to raise_error(Todoable::NotAuthenticated)
      end
    end

    describe '#delete_list' do
      let(:id) { 'todo-able-list-uuid' }

      it 'raises a Todoable::NotAuthenticated error' do
        expect { client.delete_list(id: id) }
          .to raise_error(Todoable::NotAuthenticated)
      end
    end
  end

  context 'with an expired token' do
    let(:username) { 'username' }
    let(:password) { 'password' }
    let(:client) do
      Todoable::Client.build(username: username, password: password)
    end

    before do
      client # else client won't be initialized until "the future"
      Timecop.freeze(Time.now + (20 * 60)) # advance 20 minutes
    end

    after do
      Timecop.return
    end

    describe '#lists' do
      it 'reauthenticates the client' do
        allow(client).to receive(:authenticate).and_return(true)
        client.lists
        expect(client).to have_received(:authenticate)
      end
    end

    describe '#find_list' do
      let(:list_id) { 'todo-able-list-uuid' }

      it 'reauthenticates the client' do
        allow(client).to receive(:authenticate).and_return(true)
        client.find_list(list_id)
        expect(client).to have_received(:authenticate)
      end
    end

    describe '#create_list' do
      let(:name) { 'New List' }

      it 'reauthenticates the client' do
        allow(client).to receive(:authenticate).and_return(true)
        client.create_list(name: name)
        expect(client).to have_received(:authenticate)
      end
    end

    describe '#update_list' do
      let(:id) { 'todo-able-list-uuid' }
      let(:name) { 'Not Really So Urgent Anymore' }

      it 'reauthenticates the client' do
        allow(client).to receive(:authenticate).and_return(true)
        client.update_list(list_id: id, name: name)
        expect(client).to have_received(:authenticate)
      end
    end

    describe '#delete_list' do
      let(:id) { 'todo-able-list-uuid' }

      it 'reauthenticates the client' do
        allow(client).to receive(:authenticate).and_return(true)
        client.delete_list(id: id)
        expect(client).to have_received(:authenticate)
      end
    end
  end

  context 'with an authenticated client' do
    let(:username) { 'username' }
    let(:password) { 'password' }
    let(:client) do
      Todoable::Client.build(username: username, password: password)
    end

    describe '#lists' do
      let(:endpoint) { '/lists' }

      it 'calls the list endpoint' do
        allow(client.class).to receive(:get)
          .and_call_original
        client.lists
        expect(client.class).to have_received(:get)
          .with(endpoint, Hash)
      end

      it 'returns an array of Todoable:Lists' do
        lists = client.lists
        expect(lists).to all be_a Todoable::List
      end

      it 'sets the ID of Todoable::List items' do
        list = client.lists.first
        expect(list.id.is_a?(String)).to be(true)
      end

      it 'sets the name Todoable::List items' do
        list = client.lists.first
        expect(list.name.is_a?(String)).to be(true)
      end
    end

    describe '#find_list' do
      let(:list_id) { 'todo-able-list-uuid' }
      let(:endpoint) { "/lists/#{list_id}" }

      it 'raises an ArgumentError without a list id' do
        expect { client.find_list }.to raise_error(ArgumentError)
      end

      it 'calls the list endpoint with a list' do
        allow(client.class).to receive(:get).and_call_original
        client.find_list(list_id)
        expect(client.class).to have_received(:get)
          .with(endpoint, Hash)
      end

      it 'returns a single Todoable:List' do
        list = client.find_list(list_id)
        expect(list.is_a?(Todoable::List)).to be(true)
      end

      it 'returns a Todoable:List with Todoable::ListItems' do
        list = client.find_list(list_id)
        expect(list.items).to all be_a Todoable::ListItem
      end
    end

    describe '#create_list' do
      let(:name) { 'New List' }
      let(:endpoint) { '/lists' }
      let(:error_body) do
        File.open(
          File.expand_path(
            '../../../support/fixtures/generic_error.json',
            __FILE__
          )
        ).read
      end

      it 'raises an ArgumentError without a name' do
        expect { client.create_list }.to raise_error(ArgumentError)
      end

      it 'posts to the list endpoint with id and name' do
        allow(client.class).to receive(:post)
          .and_call_original
        client.create_list(name: name)
        expect(client.class).to have_received(:post)
          .with(endpoint, Hash)
      end

      it 'returns a single Todoable:List' do
        persisted_list = client.create_list(name: name)
        expect(persisted_list.is_a?(Todoable::List)).to be(true)
      end

      it 'has the correct list name' do
        persisted_list = client.create_list(name: name)
        expect(persisted_list.name).to eq(name)
      end

      it 'has no items' do
        persisted_list = client.create_list(name: name)
        expect(persisted_list.items).to eq([])
      end

      it 'has an id' do
        persisted_list = client.create_list(name: name)
        expect(persisted_list.id).to eq('this-is-a-list-id')
      end

      it 'returns an UnprocessableError if list with name exists' do
        stub_request(:post, /lists/)
          .to_return(status: 422, body: error_body)
        expect { client.create_list(name: name) }
          .to raise_error(Todoable::UnprocessableError)
      end
    end

    describe '#update_list' do
      let(:id) { 'todo-able-list-uuid' }
      let(:name) { 'Not Really So Urgent Anymore' }
      let(:endpoint) { "/lists/#{id}" }

      it 'raises an ArgumentError without a list id' do
        expect { client.update_list(name: name) }.to raise_error(ArgumentError)
      end

      it 'patches to the list endpoint with a new name' do
        allow(client.class).to receive(:patch).and_call_original
        client.update_list(list_id: id, name: name)
        expect(client.class).to have_received(:patch)
          .with(endpoint, Hash)
      end

      # Ideally these tests would apply, but the API returns a plaintext
      # response rather than json
      xit 'returns a single Todoable:List' do
        updated_list = client.update_list(list_id: id, name: name)
        expect(updated_list.is_a?(Todoable::List)).to be(true)
      end

      xit 'has the updated list name' do
        updated_list = client.update_list(list_id: id, name: name)
        expect(updated_list.name).to eq(name)
      end

      it 'returns true' do
        response = client.update_list(list_id: id, name: name)
        expect(response).to eq(true)
      end
    end

    describe '#delete_list' do
      let(:list_id) { 'todo-able-list-uuid' }
      let(:endpoint) { "/lists/#{list_id}" }

      it 'without a list id raises an ArgumentError' do
        expect { client.delete_list }.to raise_error(ArgumentError)
      end

      it 'with an invalid list id raises a ContentNotFoundError' do
        stub_request(:delete, %r{lists\/})
          .to_return(status: 404)

        expect do
          client.delete_list(id: list_id)
        end.to raise_error(Todoable::ContentNotFoundError)
      end

      it 'deletes to the list endpoint with a list_id' do
        allow(client.class).to receive(:delete)
          .and_call_original
        client.delete_list(id: list_id)
        expect(client.class).to have_received(:delete)
          .with(endpoint, Hash)
      end

      it 'returns true' do
        response = client.delete_list(id: list_id)
        expect(response).to eq(true)
      end
    end
  end
end
