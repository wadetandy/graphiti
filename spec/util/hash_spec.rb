# frozen_string_literal: true
require "spec_helper"

RSpec.describe Graphiti::Util::Hash do
  describe ".keys" do
    it "recursively collects keys" do
      hash = {foo: {bar: {}}, baz: {}}
      expect(described_class.keys(hash)).to eq([:foo, :bar, :baz])
    end
  end
end
