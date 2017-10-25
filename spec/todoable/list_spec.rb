# frozen_string_literal: true

require 'spec_helper'
describe Todoable::List do
  let(:name) { 'Urgent Things' }
  let(:item) { described_class.new(name: name) }

  let(:json_body) do
    {
      "list": {
        "name": name
      }
    }
  end

  describe '::build_from_response' do
    context 'provided the expected hash' do
      let(:status) { :todo }
      let(:list_id) { 'todo-able-list-uuid' }
      let(:list_name) { 'Urgent Things' }
      let(:name) { 'Binge season 2' }
      let(:id) { 'todo-able-list-item-uuid' }

      let(:item_attributes) do
        {
          'name' => name,
          'src' => "#{BASE_URL}lists/#{list_id}/items/#{id}",
          'finished_at' => nil
        }
      end

      let(:item) do
        Todoable::ListItem.build_from_response(item_attributes)
      end

      let(:attributes) do
        {
          'id' => list_id,
          'name' => list_name,
          'items' => [item_attributes]
        }
      end

      let(:list) do
        described_class.build_from_response(attributes)
      end

      before do
        allow(Todoable::ListItem).to receive(:build_from_response)
          .and_return(item)
      end

      it 'returns a list with a name' do
        expect(list.name).to eq(list_name)
      end

      it 'returns a list item with an id' do
        expect(list.id).to eq(list_id)
      end

      it 'returns a list witha  single item' do
        expect(list.items).to eq([item])
      end
    end
  end

  describe '#post_body' do
    it 'serializes to the expected format for adding to list' do
      expect(item.post_body).to eq(json_body.to_json)
    end
  end

  describe '#persisted' do
    let(:item) { described_class.new(name: 'Save this!') }

    it 'returns true when an id and list id are present' do
      item.id = 'todo-able-list-uuid'
      expect(item.persisted).to eq(true)
    end

    it 'returns false when an id and list id are not present' do
      expect(item.persisted).to eq(false)
    end
  end

  describe '#attributes' do
    let(:status) { :todo }
    let(:list_id) { 'todo-able-list-uuid' }
    let(:list_name) { 'Urgent Things' }
    let(:name) { 'Binge season 2' }
    let(:id) { 'todo-able-list-item-uuid' }

    let(:item_attributes) do
      {
        'name' => name,
        'src' => "#{BASE_URL}#{list_id}/items/#{id}",
        'finished_at' => nil
      }
    end

    let(:item) { Todoable::ListItem.build_from_response(item_attributes) }

    let(:attributes) do
      {
        'id' => list_id,
        'name' => list_name,
        'items' => [item_attributes]
      }
    end

    let(:list) do
      described_class.build_from_response(attributes)
    end

    it 'returns the expected attributes' do
      expect(list.attributes).to eq(
        id: list_id,
        name: list_name,
        items: [item.attributes]
      )
    end
  end
end
