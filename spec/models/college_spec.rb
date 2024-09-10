# frozen_string_literal: true

require 'spec_helper'

describe College, type: :model do
  subject { build(:college) }

  describe 'validations' do
    it 'is valid when all attributes are present' do
      expect(subject).to be_valid
    end

    it 'is not valid without a name' do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it 'is not valid without a city' do
      subject.city = nil
      expect(subject).not_to be_valid
    end

    it 'is not valid without a state' do
      subject.state = nil
      expect(subject).not_to be_valid
    end
  end
end
