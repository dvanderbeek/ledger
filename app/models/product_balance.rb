class ProductBalance < ActiveRecord::Base
  belongs_to :account

  scope :as_of, -> (date) { where('date <= ?', date) }
  scope :by_product, -> { select("DISTINCT ON (product_uuid) *").order("product_uuid, date desc") }
  scope :positive, -> { where('amount_cents > ?', 0) }
end
