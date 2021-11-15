class Vaccine < ApplicationRecord
  validates :cvx_code, presence: true, uniqueness: true
  validates :group_name, presence: true
end