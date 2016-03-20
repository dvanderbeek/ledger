require 'rails_helper'

RSpec.describe DebitAccount do
  it "calculates the correct account balance" do
    account = Asset.new
    credits = [double(amount_cents: 100), double(amount_cents: 100)]
    debits = [double(amount_cents: 50)]

    allow(account).to receive_message_chain(:credits, :as_of, :for_product) { credits }
    allow(account).to receive_message_chain(:debits, :as_of, :for_product) { debits }

    expect(account.balance).to eq -150
  end
end
