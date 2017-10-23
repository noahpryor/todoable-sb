require 'spec_helper'

describe Todoable::ListItem do

  describe "::new" do

    context "given an item name" do
      let(:name) { "Implement this class" }
      it "returns a list item with a name" do
        item = Todoable::ListItem.new(name: name)
        expect(item).to be_a(Todoable::ListItem)
        expect(item.name).to eq(name)
      end
    end

    context "without an item name" do

      xit "does not make an API call" do


      end

      it "raises an error" do
        expect{ Todoable::ListItem.new() }.to raise_error(ArgumentError)
      end
    end
  end

  context "given an initialized but not saved ListItem" do
    let (:name) { "Feed the cat" }
    let (:item) { Todoable::ListItem.new(name: name)}
    let (:json_body) {
      {
        "item": {
          "name": name
        }
      }
    }

    describe "#as_json" do
      it "serializes to the expected format for adding to list" do
        expect(item.as_json).to eq(json_body)
      end
    end
  end

  context "given a persisted ListItem" do
    let (:name) { "Feed the cat" }
    let (:id) { "list-item-uuid" }
    let (:list_id) { "list-uuid" }
    let (:item) { Todoable::ListItem.new(name: name)}

    before do
      item.id = id
      item.list_id = list_id
    end

    describe "#delete" do

      xit "deletes the item from the list" do

      end
    end

    describe "#finish" do
      it "marks the item as finished" do
        item.finish
        expect(item.status).to eq(:finished)
      end

    end
  end
end
