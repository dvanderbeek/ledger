class Txn
  class Reversal < ::Txn
    belongs_to :parent, inverse_of: :reversals, class_name: Txn

    before_validation :set_defaults, on: :create

    private

    def set_defaults
      self.date ||= self.parent.date
      self.product_uuid ||= self.parent.product_uuid

      parent.debits.each do |debit|
        credits.build(debit.attributes.except('id', 'created_at', 'updated_at', 'type'))
      end

      parent.credits.each do |credit|
        debits.build(credit.attributes.except('id', 'created_at', 'updated_at', 'type'))
      end
    end
  end
end
