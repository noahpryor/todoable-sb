# frozen_string_literal: true

require 'spec_helper'

describe Todoable::Api::List do
  context 'with an authenticated client' do
    let (:username) { 'username' }
    let (:password) { 'password' }
    let (:client) { Todoable::Client.build(username: username, password: password) }

    describe '#lists' do
      it 'calls the list endpoint' do
        endpoint = '/lists'

        expect(client.class).to receive(:get)
          .with(endpoint, Hash)
          .and_call_original
        client.lists
      end

      context 'and receives a valid response' do
        it 'returns an array of Todoable:Lists' do
          lists = client.lists
          expect(lists).to all be_a Todoable::List
        end

        it 'sets the name and ID of Todoable::List items' do
          list = client.lists.first
          expect(list.name.is_a?(String)).to be(true)
          expect(list.id.is_a?(String)).to be(true)
        end
      end

      context 'and receives an unauthorized response' do
        before do
          stub_request(:get, /lists/)
            .to_return(status: 401)
        end

        it 'raises a Todoable::Unauthorized error' do
          expect { client.lists }.to raise_error(Todoable::UnauthorizedError)
        end
      end
    end

    describe '#find_list' do
      context 'without a list id' do
        it 'raises an ArgumentError' do
          expect { client.find_list }.to raise_error(ArgumentError)
        end
      end

      context 'with a list id' do
        let (:list_id) { 'todo-able-list-uuid' }

        it 'calls the list endpoint' do
          endpoint = "/lists/#{list_id}"

          expect(client.class).to receive(:get)
            .with(endpoint, Hash)
            .and_call_original
          client.find_list(list_id)
        end

        context 'and receives a valid response' do
          it 'returns a single Todoable:List' do
            list = client.find_list(list_id)
            expect(list.is_a?(Todoable::List)).to be(true)
          end

          it 'returns a Todoable:List with Todoable::ListItems' do
            list = client.find_list(list_id)
            expect(list.items).to all be_a Todoable::ListItem
          end
        end

        context 'and receives an unauthorized response' do
          before do
            stub_request(:get, /lists/)
              .to_return(status: 401)
          end

          it 'raises a Todoable::Unauthorized error' do
            expect { client.lists }.to raise_error(Todoable::UnauthorizedError)
          end
        end
      end
    end

    describe '#create_list' do
      let (:name) { 'New List' }

      context 'without a name' do
        it 'raises an ArgumentError' do
          expect { client.create_list }.to raise_error(ArgumentError)
        end
      end

      context 'with a name' do
        it 'posts to the list endpoint' do
          endpoint = '/lists'
          expect(client.class).to receive(:post)
            .with(endpoint, Hash)
            .and_call_original
          client.create_list(name: name)
        end

        context 'and receives a valid response' do
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
        end

        context 'and receives an unauthorized response' do
          before do
            stub_request(:post, /lists/)
              .to_return(status: 401)
          end

          it 'raises a Todoable::Unauthorized error' do
            expect do
              client.create_list(name: name)
            end.to raise_error(Todoable::UnauthorizedError)
          end
        end
      end
    end

    describe '#update' do
      let (:id) { 'todo-able-list-uuid' }
      let (:name) { 'Not Really So Urgent Anymore' }

      context 'without a list id' do
        it 'raises an ArgumentError' do
          expect { client.update(name: name) }.to raise_error(ArgumentError)
        end
      end

      context 'with a new name ' do
        it 'patches to the list endpoint' do
          endpoint = "/lists/#{id}"

          expect(client.class).to receive(:patch)
            .with(endpoint, Hash)
            .and_call_original
          client.update(list_id: id, name: name)
        end

        context 'and receives a valid response' do
          # Ideally these tests would apply, but the API returns a plaintext
          # response rather than json
          xit 'returns a single Todoable:List' do
            updated_list = client.update(list_id: id, name: name)
            expect(updated_list.is_a?(Todoable::List)).to be(true)
          end

          xit 'has the updated list name' do
            updated_list = client.update(list_id: id, name: name)
            expect(updated_list.name).to eq(name)
          end

          it 'returns true' do
            response = client.update(list_id: id, name: name)
            expect(response).to eq(true)
          end
        end

        context 'and receives an unauthorized response' do
          before do
            stub_request(:patch, /lists\//)
              .to_return(status: 401)
          end

          it 'raises a Todoable::Unauthorized error' do
            expect do
              client.update(list_id: id, name: name)
            end.to raise_error(Todoable::UnauthorizedError)
          end
        end
      end
    end

    describe '#delete_list' do
      context 'without a list id' do
        it 'raises an ArgumentError' do
          expect { client.delete_list }.to raise_error(ArgumentError)
        end
      end

      context 'without an invalid list id' do
        let (:list_id) { 'not-a-valid-id' }

        before do
          stub_request(:delete, /lists\//)
            .to_return(status: 404)
        end

        it 'raises a ContentNotFoundError' do
          expect do
            client.delete_list(id: list_id)
          end.to raise_error(Todoable::ContentNotFoundError)
        end
      end

      context 'with a valid list id' do
        let (:id) { 'todo-able-list-uuid' }

        it 'deletes to the list endpoint' do
          endpoint = "/lists/#{id}"
          expect(client.class).to receive(:delete)
            .with(endpoint, Hash)
            .and_call_original
          client.delete_list(id: id)
        end

        context 'and receives a valid response' do
          it 'returns true' do
            response = client.delete_list(id: id)
            expect(response).to eq(true)
          end
        end

        context 'and receives an unauthorized response' do
          before do
            stub_request(:delete, /lists\//)
              .to_return(status: 401)
          end

          it 'raises a Todoable::Unauthorized error' do
            expect { client.delete_list(id: id) }.to raise_error(Todoable::UnauthorizedError)
          end
        end
      end
    end
  end
end
