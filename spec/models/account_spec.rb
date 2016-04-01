require 'rails_helper'

RSpec.describe Account, type: :model do
  context "associations" do
    it { is_expected.to have_many(:entries) }
    it { is_expected.to have_many(:debits) }
    it { is_expected.to have_many(:credits) }
  end

  context "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe ".named" do
    it "finds an account by name" do
      account = create(:account, name: :test123)

      expect(Account).to receive(:find_by).with(name: :test123).and_return(account)

      expect(Account.test123).to eq account
    end
  end
end
