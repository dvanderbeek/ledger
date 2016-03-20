require 'rails_helper'

RSpec.describe Entry, type: :model do
  context "associations" do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:txn) }
  end

  context "validations" do
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:account) }
    it { is_expected.to validate_presence_of(:txn) }
    it { is_expected.to validate_presence_of(:amount_cents) }
  end

  it "has a default date" do
    expect(Entry.new.date).to eq Date.current
  end

  describe ".for_product" do
    it "returns the correct records" do
      entry_1 = create(:entry, product_uuid: 1)
      entry_2 = create(:entry, product_uuid: 2)
      query = Entry.for_product(1)

      expect(query).to include(entry_1)
      expect(query).not_to include(entry_2)
    end
  end

  describe ".as_of" do
    it "returns the correct records" do
      old_entry = create(:entry, date: 1.year.ago)
      new_entry = create(:entry, date: Date.current)
      query = Entry.as_of(Date.yesterday)

      expect(query).to include(old_entry)
      expect(query).not_to include(new_entry)
    end
  end

  describe "#account_name=" do
    it "sets the account when given a name" do
      account = create(:account)
      entry = Entry.new(account_name: account.name)

      expect(entry.account).to eq account
    end
  end
end
