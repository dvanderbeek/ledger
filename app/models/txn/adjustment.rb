class Txn
  class Adjustment < ::Txn
    belongs_to :parent, inverse_of: :adjustments, class_name: Txn

    before_validation :set_defaults, on: :create

    private

    def set_defaults
      self.date ||= self.parent.date
      self.product_uuid ||= self.parent.product_uuid
    end
  end
end
