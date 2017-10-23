require 'spec_helper'

describe Sb::Todoable::List do

  describe "::all" do
    it "returns an array of lists" do
      lists = Sb::Todoable::List.all
      expect(lists).to be_an Array
    end
  end

  describe "::create" do
    it "creates a list with a name attribute" do
      name = "My New List"
      list = Sb::Todoable::List::create(name)
      expect(list.class).to eq Sb::Todoable::List
      expect(list.name).to eq name
    end
  end

  describe "::find" do
    context "given a valid list ID" do

      it "finds the proper list" do

      end

      it "includes the list items in the found list" do

      end
    end

    context "given an invalid list ID" do

      it "raises a Todoable::NotFound error" do

      end
    end

    context "with an instantiated List instance" do

      describe "#update" do

      end

      describe "#destroy" do

      end

      describe "#add_item" do

      end
    end
  end
end
