# frozen_string_literal: true

require 'spec_helper'
BASE_URL = 'http://todoable.teachable.tech/api/'.freeze
describe Todoable::ListItem do
  let (:name) { 'Feed the cat' }
  let (:item) { described_class.new(name: name) }
  let (:json_body) do
    {
      "item": {
        "name": name
      }
    }
  end

  describe '::new' do
    context 'given an item name' do
      it 'returns a list item with a name' do
        item = described_class.new(name: name)
        expect(item.is_a?(described_class)).to be(true)
        expect(item.name).to eq(name)
      end
    end

    context 'without an item name' do
      it 'raises an error' do
        expect { described_class.new }.to raise_error(ArgumentError)
      end
    end
  end

  describe '::build_from_response' do
    context 'provided the expected json' do
      let (:status) { :todo }
      let (:list_id) { 'todo-able-list-uuid' }
      let (:name) { 'Urgent Things' }
      let (:id) { 'todo-able-list-item-uuid' }

      let (:item_attributes) do
        {
          'name' => name,
          'src' => "#{BASE_URL}lists/#{list_id}/items/#{id}",
          'finished_at' => nil
        }
      end

      let (:item) do
        described_class.build_from_response(item_attributes)
      end

      it 'returns a list item with a name' do
        expect(item.name).to eq(name)
      end

      it 'returns a list item with a list id' do
        expect(item.list_id).to eq(list_id)
      end

      it 'returns a list item with an id' do
        expect(item.id).to eq(id)
      end

      it 'returns a list item with a status' do
        expect(item.status).to eq(status)
      end
    end
  end

  describe '#post_body' do
    it 'serializes to the expected format for adding to list' do
      expect(item.post_body).to eq(json_body.to_json)
    end
  end

  describe '#persisted' do
    let (:item) { described_class.new(name: 'Save this!') }

    it 'returns true when an id and list id are present' do
      item.id = 'todo-able-list-item-uuid'
      item.list_id = 'todo-able-list-uuid'
      expect(item.persisted).to eq(true)
    end

    it 'returns false when an id and list id are not present' do
      expect(item.persisted).to eq(false)
    end
  end

  describe '#attributes' do
    let (:status) { :todo }
    let (:list_id) { 'todo-able-list-uuid' }
    let (:name) { 'Binge season 2' }
    let (:id) { 'todo-able-list-item-uuid' }

    let (:item_attributes) do
      {
        'name' => name,
        'src' => "#{BASE_URL}lists/#{list_id}/items/#{id}",
        'finished_at' => nil
      }
    end

    let (:item) do
      described_class.build_from_response(item_attributes)
    end

    it 'returns the expected attributes' do
      expect(item.attributes).to eq(
        id: id,
        name: name,
        status: status,
        list_id: list_id
      )
    end
  end
end
