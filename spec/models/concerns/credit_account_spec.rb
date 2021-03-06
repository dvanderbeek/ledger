require 'rails_helper'

class StubCreditAccount < Account; include CreditAccount; end

RSpec.describe CreditAccount do
  it "calculates the correct account balance" do
    account = StubCreditAccount.new
    credits = [double(amount_cents: 100), double(amount_cents: 100)]
    debits = [double(amount_cents: 50)]

    allow(account).to receive_message_chain(:credits, :as_of, :for_product) { credits }
    allow(account).to receive_message_chain(:debits, :as_of, :for_product) { debits }

    expect(account.balance_for_new_record).to eq 150
  end

  it "handles no credits" do
    account = StubCreditAccount.new
    credits = []
    debits = [double(amount_cents: 50)]

    allow(account).to receive_message_chain(:credits, :as_of, :for_product) { credits }
    allow(account).to receive_message_chain(:debits, :as_of, :for_product) { debits }

    expect(account.balance_for_new_record).to eq -50
  end

  it "handles no debits" do
    account = StubCreditAccount.new
    credits = [double(amount_cents: 100), double(amount_cents: 100)]
    debits = []

    allow(account).to receive_message_chain(:credits, :as_of, :for_product) { credits }
    allow(account).to receive_message_chain(:debits, :as_of, :for_product) { debits }

    expect(account.balance_for_new_record).to eq 200
  end
end
