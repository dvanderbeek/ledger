require 'rails_helper'

RSpec.describe Txn, type: :model do
  context "associations" do
    it { is_expected.to have_many(:entries) }
    it { is_expected.to have_many(:debits) }
    it { is_expected.to have_many(:credits) }
  end

  it { is_expected.to respond_to(:date) }
  it { is_expected.to respond_to(:product_uuid) }

  context "validations" do
    it { is_expected.to validate_presence_of(:name) }

    it "is invalid with mismatching debits and credits" do
      txn = build_stubbed(:txn, credits: { interest_income: 100 })

      txn.valid?
      expect(txn.errors[:base]).to include(I18n.t('txn.errors.unbalanced'))
    end

    it "is valid with matching debits and credits" do
      txn = build_stubbed(:txn)

      txn.valid?
      expect(txn.errors[:base]).not_to include(I18n.t('txn.errors.unbalanced'))
    end
  end

  it "sets up Debits and Credits" do
    txn = build_stubbed(:txn,
      debits: { accounts_receivable: 3000 },
      credits: { interest_income: 2000, principal: 1000 },
    )

    expect(txn.debits.length).to eq 1
    expect(txn.credits.length).to eq 2
  end
end
