# frozen_string_literal: true

require "spec_helper"

RSpec.describe SimplerCommand::Errors do
  subject(:errors) { described_class.new }

  describe "#add" do
    it "wraps error messages in an array" do
      errors.add(:foo, "is not working")

      expect(errors[:foo]).to eq ["is not working"]
    end

    it "ignores duplicate error messages" do
      errors.add(:foo, "is broken")
      errors.add(:foo, "is broken")

      expect(errors[:foo]).to eq ["is broken"]
    end
  end

  describe "#add_all" do
    it "adds all errors from another errors object", :aggregate_failures do
      other_errors = described_class.new
      other_errors.add(:bar, "is not working")

      errors.add(:foo, "is broken")
      errors.add_all(other_errors)

      expect(errors[:foo]).to eq ["is broken"]
      expect(errors[:bar]).to eq ["is not working"]
    end

    it "supports adding a hash with a message array", :aggregate_failures do
      other_errors = {
        bar: ["is not working"]
      }

      errors.add(:foo, "is broken")
      errors.add_all(other_errors)

      expect(errors[:foo]).to eq ["is broken"]
      expect(errors[:bar]).to eq ["is not working"]
    end

    it "supports an ActiveModel::Errors hash", :as_only do
      other_errors = ActiveModel::Errors.new(Object.new)
      other_errors.add(:bar, "won't work")

      errors.add(:foo, "is broken")
      errors.add_all(other_errors)

      expect(errors[:foo]).to eq ["is broken"]
      expect(errors[:bar]).to eq ["won't work"]
    end
  end

  describe "#each" do
    it "iterates through each key and message", :aggregate_failures do
      found_keys = []
      found_messages = []

      errors.add(:foo, "is not working")
      errors.add(:bar, "is not suitable")
      errors.add(:foo, "will never work")

      errors.each do |key, message|
        found_keys << key
        found_messages << message
      end

      expect(found_keys).to eq %i[foo foo bar]
      expect(found_messages).to eq ["is not working", "will never work", "is not suitable"]
    end
  end

  describe "#full_messages" do
    it "includes the titleized key name" do
      errors.add(:foo, "is not working")

      expect(errors.full_messages).to eq ["Foo is not working"]
    end

    it "allows for errors on multiple keys" do
      errors.add(:foo, "is not working")
      errors.add(:bar, "is not suitable")

      expect(errors.full_messages).to eq ["Foo is not working", "Bar is not suitable"]
    end

    it "allows for multiple errors on a single key" do
      errors.add(:foo, "is not working")
      errors.add(:foo, "will never work")

      expect(errors.full_messages).to eq ["Foo is not working", "Foo will never work"]
    end

    it "excludes the base label from the error" do
      errors.add(:base, "This is a message")

      expect(errors.full_messages).to eq ["This is a message"]
    end

    it "humanizes key names" do
      errors.add(:foo_bar_baz, "is broken")

      expect(errors.full_messages).to eq ["Foo bar baz is broken"]
    end
  end

  describe "#to_hash" do
    context "with ActiveSupport included", :as_only do
      it "returns a hash representation of the errors" do
        errors.add(:foo, "is not working")
        errors.add(:bar, "is not suitable")

        expect(errors.to_hash).to eq(
          foo: ["is not working"],
          bar: ["is not suitable"]
        )
      end
    end
  end

  describe "#to_hash", :as_only do
    it "returns a JSON representation of the errors object" do
      errors.add(:foo, "is not working")
      errors.add(:bar, "is not suitable")

      expect(errors.to_hash).to eq(
        foo: ["is not working"],
        bar: ["is not suitable"]
      )
    end
  end

  describe "#as_json", :as_only do
    it "returns a JSON representation of the errors object" do
      errors.add(:foo, "is not working")
      errors.add(:bar, "is not suitable")

      expect(errors.as_json).to eq(
        "foo" => ["is not working"],
        "bar" => ["is not suitable"]
      )
    end
  end
end
