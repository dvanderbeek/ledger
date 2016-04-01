class Txn
  class Adjustment < ::Txn
    belongs_to :parent, class_name: Txn, inverse_of: :reversals

    validates :parent, presence: true
    validate :date_equals_parent

    after_initialize :set_defaults

    private

    def date_equals_parent
      if self.date.present? && self.date != parent.date
        errors.add(:date, I18n.t('txn.errors.date_does_not_match_parent'))
      end
    end

    def set_defaults
      # self.date = parent.date
      # self.product_uuid = parent.product_uuid
    end
  end
end
