require 'spec_helper'
require_relative '../lib/pul_solr'

describe PulSolr do
  describe "configs" do
    it "loads configs" do
      expect(PulSolr.collections).to be_a Hash
    end
  end
end
