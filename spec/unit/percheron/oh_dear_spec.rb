require 'unit/spec_helper'

describe Percheron::OhDear do
  let(:exception) { StandardError.new('oh my') }

  subject { described_class.new(exception) }

  describe '#generate' do
    it 'prints out information to create issue' do
      expect(subject.generate).to match(/#<StandardError: oh my>/)
    end
  end
end
