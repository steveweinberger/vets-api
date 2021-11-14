class Vaccine < ApplicationRecord
  validates :cvx_number, presence: true, uniqueness: true
  validates :group_name, presence: true
end