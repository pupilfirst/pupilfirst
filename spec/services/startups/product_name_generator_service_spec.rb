require 'rails_helper'

describe Startups::ProductNameGeneratorService do
  describe '#fun_name' do
    it "returns a color followed by a scientist's name" do
      expect(subject.fun_name).to match(/[A-Z][a-z]+\s[A-Z][a-z]+/)
    end
  end
end
