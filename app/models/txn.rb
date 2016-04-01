class Txn < ActiveRecord::Base
  has_many :entries, dependent: :destroy
  has_many :debits, inverse_of: :txn, class_name: Entry::Debit
  has_many :credits, inverse_of: :txn, class_name: Entry::Credit

  validates :name, presence: true
  validate :date_cannot_be_in_the_future
  validate :debits_equal_credits

  after_initialize :set_defaults, if: :new_record?

  scope :for_product, -> (uuid) { uuid.present? ? where(product_uuid: uuid) : all }
  scope :as_of, -> (date) { where("date <= ?", date) }
  scope :between, -> (date_range) { where(date: date_range) }

  %w[debits credits].each do |entry_type|
    define_method("#{entry_type}=") do |hash|
      hash.each do |key, value|
        self.send(entry_type).new(
          account: Account.find_by(name: key),
          amount_cents: value,
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

  def date_cannot_be_in_the_future
    if self.date.present? && self.date > Date.current
      errors.add(:date, I18n.t('txn.errors.date_in_future'))
    end
  end

  def set_defaults
    self.date ||= Date.current
  end
end
