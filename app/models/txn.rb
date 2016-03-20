class Txn < ActiveRecord::Base
  has_many :entries
  has_many :debits
  has_many :credits

  attr_accessor :product_uuid

  validates :name, presence: true
  validate :debits_equal_credits

  %w[debits credits].each do |entry_type|
    define_method("#{entry_type}=") do |hash|
      hash.each do |key, value|
        self.send(entry_type).new(
          txn: self,
          account_name: key,
          amount_cents: value,
          product_uuid: product_uuid
        )
      end
    end
  end

  private

  def debits_equal_credits
    unless balanced?
      errors.add(:base, I18n.t('txn.errors.unbalanced'))
    end
  end

  def balanced?
    debits.map(&:amount_cents).reduce(:+) ==
      credits.map(&:amount_cents).reduce(:+)
  end
end
