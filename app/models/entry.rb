class Entry < ActiveRecord::Base
  belongs_to :account
  belongs_to :txn

  validates :date, :account, :txn, :amount_cents, presence: true

  after_initialize :set_defaults

  scope :for_product, -> (uuid) { uuid.present? ? where(product_uuid: uuid) : all }
  scope :as_of, -> (date) { where("date <= ?", date) }

  def account_name=(name)
    self.account = Account.find_by(name: name) if name
  end

  private

  def set_defaults
    self.date ||= Date.current
  end
end
