class Account < ActiveRecord::Base
  has_many :entries
  has_many :debits
  has_many :credits

  validates :name, presence: true, uniqueness: true

  def self.named(name)
    find_by(name: name)
  end
end
