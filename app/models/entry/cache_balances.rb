class Entry
  class CacheBalances
    attr_reader :entry

    delegate :account, :balance_change_cents, :product_uuid, :txn_date, to: :entry

    def initialize(entry)
      @entry = entry
    end

    def call
      update_account_balances
      update_product_balances
      update_future_product_balances
    end

    private

    def update_account_balances
      account.path.update_all("balance_cents = balance_cents + #{balance_change_cents}")
    end

    def update_product_balances
      account.path.each do |account|
        ProductBalance.find_or_create_by(account: account, date: txn_date, product_uuid: product_uuid) do |product_balance|
          product_balance.amount_cents = ProductBalance.where(account: account, product_uuid: product_uuid)
                                                       .where('date < ?', txn_date)
                                                       .order(:date).last.try(:amount_cents) || 0
        end
      end
    end

    def update_future_product_balances
      ProductBalance.where('date >= ?', txn_date)
                    .where(account: account.path, product_uuid: product_uuid)
                    .update_all("amount_cents = amount_cents + #{balance_change_cents}")
    end
  end
end
