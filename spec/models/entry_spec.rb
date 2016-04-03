require 'rails_helper'

RSpec.describe Entry, type: :model do
  context "associations" do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:txn) }
  end

  context "validations" do
    it { is_expected.to validate_presence_of(:account) }
    it { is_expected.to validate_presence_of(:txn) }
    it { is_expected.to validate_presence_of(:amount_cents) }
  end

  describe ".for_product" do
    before do
      create(:account, name: :accounts_receivable)
      create(:account, name: :interest_income)
    end

    it "returns the correct records" do
      txn1 = create(:txn,
        product_uuid: 1,
        debits: { accounts_receivable: 3000 },
        credits: { interest_income: 3000 },
      )

      txn2 = create(:txn,
        product_uuid: 2,
        debits: { accounts_receivable: 2000 },
        credits: { interest_income: 2000 },
      )

      query = Entry.for_product(1)

      expect(Entry.count).to eq 4
      expect(query.count).to eq 2
    end
  end

  describe ".as_of" do
    before do
      create(:account, name: :accounts_receivable)
      create(:account, name: :interest_income)
    end

    it "returns the correct records" do
      txn1 = create(:txn,
        product_uuid: 1,
        date: 1.year.ago,
        debits: { accounts_receivable: 3000 },
        credits: { interest_income: 3000 },
      )

      txn2 = create(:txn,
        product_uuid: 2,
        debits: { accounts_receivable: 2000 },
        credits: { interest_income: 2000 },
      )

      query = Entry.as_of(Date.yesterday)

      expect(Entry.count).to eq 4
      expect(query.count).to eq 2
    end
  end
end
