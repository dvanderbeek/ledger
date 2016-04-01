class Txn < ActiveRecord::Base
  include DefaultDate

  has_many :entries, dependent: :destroy
  has_many :debits, class_name: Entries::Debit
  has_many :credits, class_name: Entries::Credit

  validates :name, presence: true
  validate :debits_equal_credits

  scope :for_product, -> (uuid) { uuid.present? ? where(product_uuid: uuid) : all }
  scope :as_of, -> (date) { where("date <= ?", date) }
  scope :between, -> (date_range) { where(date: date_range) }

  %w[debits credits].each do |entry_type|
    define_method("#{entry_type}=") do |hash|
      hash.each do |key, value|
        self.send(entry_type).new(
          txn: self,
          date: self.date,
          account: Account.find_by(name: key),
          amount_cents: value,
          product_uuid: product_uuid,
        )
      end
    end
  end

  private

  def debits_equal_credits
    errors.add(:base, I18n.t('txn.errors.unbalanced')) unless balanced?
  end

  def balanced?
    debits.map(&:amount_cents).reduce(:+) ==
      credits.map(&:amount_cents).reduce(:+)
  end
end
