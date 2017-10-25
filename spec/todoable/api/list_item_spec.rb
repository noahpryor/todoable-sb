# frozen_string_literal: true

require 'spec_helper'

describe Todoable::Api::ListItem do
  context 'with an authenticated client' do
    let(:username) { 'username' }
    let(:password) { 'password' }
    let(:client) do
      Todoable::Client.build(username: username, password: password)
    end

    describe '#create_item' do
      let(:list_id) { 'todo-able-list-uuid' }
      let(:name) { 'Urgent Things' }

      context 'without a list_id' do
        it 'raises an ArgumentError' do
          expect { client.create_item(name: name) }
            .to raise_error(ArgumentError)
        end
      end

      context 'without a name' do
        it 'raises an ArgumentError' do
          expect { client.create_item(list_id: list_id) }
            .to raise_error(ArgumentError)
        end
      end

      context 'with an invalid list_id' do
        before do
          stub_request(:post, /lists/)
            .to_return(status: 404)
        end

        it 'raises a ContentNotFoundError' do
          expect do
            client.create_item(list_id: list_id, name: name)
          end.to raise_error(Todoable::ContentNotFoundError)
        end
      end

      context 'with a valid list_id' do
        let(:endpoint) { "/lists/#{list_id}/items" }

        it 'posts to the list items endpoint' do
          allow(client.class).to receive(:post)
            .and_call_original
          client.create_item(list_id: list_id, name: name)
          expect(client.class).to have_received(:post)
            .with(endpoint, Hash)
        end

        context 'and receives a valid response' do
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
      end
    end

    describe '#finish' do
      let(:id) { 'todo-able-list-item-uuid' }
      let(:list_id) { 'todo-able-list-uuid' }

      context 'without a list id' do
        it 'raises an ArgumentError' do
          expect { client.finish(id: id) }.to raise_error(ArgumentError)
        end
      end

      context 'without an item id' do
        it 'raises an ArgumentError' do
          expect { client.finish(list_id: list_id) }
            .to raise_error(ArgumentError)
        end
      end

      context 'with invalid IDs' do
        before do
          stub_request(:put, /lists/)
            .to_return(status: 404)
        end

        context 'with an invalid list id' do
          it 'raisea a ContentNotFoundError' do
            expect do
              client.finish(id: id, list_id: list_id)
            end.to raise_error(Todoable::ContentNotFoundError)
          end
        end

        context 'with an invalid item id' do
          it 'raisea a ContentNotFoundError' do
            expect do
              client.finish(id: id, list_id: list_id)
            end.to raise_error(Todoable::ContentNotFoundError)
          end
        end
      end

      context 'with valid IDs' do
        let(:endpoint) { "/lists/#{list_id}/items/#{id}/finish" }

        it 'puts to the list items finish endpoint' do
          allow(client.class).to receive(:put)
            .and_call_original
          client.finish(id: id, list_id: list_id)
          expect(client.class).to have_received(:put)
            .with(endpoint, Hash)
        end

        context 'and receives a valid response' do
          it 'returns true' do
            result = client.finish(id: id, list_id: list_id)
            expect(result).to eq(true)
          end
        end

        context 'and receives an unauthorized response' do
          before do
            stub_request(:put, /lists\//)
              .to_return(status: 401)
          end

          it 'raises a Todoable::Unauthorized error' do
            expect { client.finish(id: id, list_id: list_id) }
              .to raise_error(Todoable::UnauthorizedError)
          end
        end
      end
    end

    describe '#delete' do
      let(:id) { 'todo-able-list-item-uuid' }
      let(:list_id) { 'todo-able-list-uuid' }

      context 'without a list id' do
        it 'raises an ArgumentError' do
          expect { client.delete(id: id) }.to raise_error(ArgumentError)
        end
      end

      context 'without an item id' do
        it 'raises an ArgumentError' do
          expect { client.delete(list_id: list_id) }
            .to raise_error(ArgumentError)
        end
      end

      context 'with invalid IDs' do
        before do
          stub_request(:delete, /lists/)
            .to_return(status: 404)
        end

        context 'with an invalid list id' do
          it 'raisea a ContentNotFoundError' do
            expect { client.delete(id: id, list_id: list_id) }
              .to raise_error(Todoable::ContentNotFoundError)
          end
        end

        context 'with an invalid item id' do
          it 'raisea a ContentNotFoundError' do
            expect do
              client.delete(id: id, list_id: list_id)
            end.to raise_error(Todoable::ContentNotFoundError)
          end
        end
      end

      context 'with valid IDs' do
        let(:endpoint) { "/lists/#{list_id}/items/#{id}" }

        it 'puts to the list items finish endpoint' do
          allow(client.class).to receive(:delete)
            .and_call_original
          client.delete(id: id, list_id: list_id)
          expect(client.class).to have_received(:delete)
            .with(endpoint, Hash)
        end

        context 'and receives a valid response' do
          it 'returns true' do
            result = client.delete(id: id, list_id: list_id)
            expect(result).to eq(true)
          end
        end

        context 'and receives an unauthorized response' do
          before do
            stub_request(:delete, /lists\//)
              .to_return(status: 401)
          end

          it 'raises a Todoable::Unauthorized error' do
            expect { client.delete(id: id, list_id: list_id) }
              .to raise_error(Todoable::UnauthorizedError)
          end
        end
      end
    end
  end
end
