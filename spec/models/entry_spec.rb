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
      entry_1 = Entry.new(product_uuid: 1)
      entry_2 = Entry.new(product_uuid: 2)
      entry_1.save(validate: false)
      entry_2.save(validate: false)

      query = Entry.for_product(1)

      expect(query).to include(entry_1)
      expect(query).not_to include(entry_2)
    end
  end

  describe ".as_of" do
    it "returns the correct records" do
      entry_1 = Entry.new(date: 1.year.ago)
      entry_2 = Entry.new(date: Date.current)
      entry_1.save(validate: false)
      entry_2.save(validate: false)

      query = Entry.as_of(Date.yesterday)

      expect(query).to include(entry_1)
      expect(query).not_to include(entry_2)
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
