class Txn < ActiveRecord::Base
  has_many :entries
  has_many :debits
  has_many :credits

  attr_accessor :date, :product_uuid

  validates :name, presence: true
  validate :debits_equal_credits

  %w[debits credits].each do |entry_type|
    define_method("#{entry_type}=") do |hash|
      hash.each do |key, value|
        self.send(entry_type).new(
          txn: self,
          date: self.date || Date.current,
          account_name: key,
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
