require 'spec_helper'

describe Todoable::List do
  context "given an initialized but not persisted List" do
    let (:name) { "Urgent Things" }
    let (:item) { Todoable::List.new(name: name)}

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

    describe "#persisted" do
      let (:item) { Todoable::List.new(name: "Save this!") }

      it "returns true when an id and list id are present" do
        item.id = 'todo-able-list-uuid'
        expect(item.persisted).to eq(true)
      end

      it "returns false when an id and list id are not present" do
        expect(item.persisted).to eq(false)
      end
    end

  end
end
