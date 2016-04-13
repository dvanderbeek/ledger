class ProductBalance < ActiveRecord::Base
  belongs_to :account

  scope :as_of, -> (date) { where('date <= ?', date) }
  scope :by_product, -> { select("DISTINCT ON (product_uuid) *").order("product_uuid, date desc") }
  scope :for_accounts, -> (*names) { joins(:account).merge(Account.where(name: names)) }
  scope :for_product, -> (uuid) { where(product_uuid: uuid) }
  scope :positive, -> { where('amount_cents > ?', 0) }

  def self.by_account
    includes(:account).each_with_object({}) do |product_balance, hsh|
      hsh[product_balance.account] = product_balance.amount_cents
    end
  end
end
