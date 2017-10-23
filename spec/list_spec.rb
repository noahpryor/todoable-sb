require 'spec_helper'

describe Todoable::List do

  describe "::all" do
    it "returns an array of lists" do
      lists = Todoable::List.all
      expect(lists).to be_an Array
      expect(lists).to all be_a Todoable::List
    end
  end

  describe "::create" do
    it "creates a list with a name attribute" do
      name = "My New List"
      list = Todoable::List::create(name: name)
      expect(list.class).to eq Todoable::List
      expect(list.name).to eq name
    end
  end

  describe "::find" do
    context "given a valid list ID" do
      let (:list_id) {"this-is-a-list-id"}

      it "finds the proper list" do
        list = Todoable::List.find(list_id)
        expect(list.id).to eq(list_id)
      end

      it "includes the list items in the found list" do
        list = Todoable::List.find(list_id)
        expect(list.items).to be_an Array
      end
    end

    context "given an invalid list ID" do

      xit "raises a Todoable::NotFound error" do

      end
    end

    context "with an instantiated List instance" do
      let (:id) { 'this-is-a-list-id' }
      let (:name) { 'Urgent Things' }
      let (:items) { [] }

      let (:list) { Todoable::List.new(
        id: id,
        name: name,
        items: items
      )}

      describe "#update" do
        it "updates the list name" do
          new_name = "Stranger Things"
          list.update(name: new_name)
          expect(list.name).to eq(new_name)
        end

      end

      describe "#destroy" do

      end

      describe "#add_item" do
        it "increases the number of list items by one" do
          item = {name: "implement list item"}
          count = list.items.count
          list.add_item(item)
          expect(list.items.count).to eq(count + 1)
        end
      end
    end
  end
end
