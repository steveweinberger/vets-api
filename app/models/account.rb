# frozen_string_literal: true

# Account's purpose is to correlate unique identifiers, and to
# remove our dependency on third party services for a user's
# unique identifier.
#
# The account.uuid is intended to become the Vets-API user's uuid.
#
class Account < ApplicationRecord
  has_many :notifications, dependent: :destroy
  has_many :preferred_facilities, dependent: :destroy, inverse_of: :account
  has_one  :login_stats,
           class_name: 'AccountLoginStat',
           dependent: :destroy,
           inverse_of: :account

  validates :uuid, presence: true, uniqueness: true
  validates :idme_uuid, uniqueness: true, allow_nil: true
  validates :logingov_uuid, uniqueness: true, allow_nil: true
  validates :idme_uuid, presence: true, unless: -> { sec_id.present? || logingov_uuid.present? }
  validates :sec_id, presence: true, uniqueness: true, unless: -> { idme_uuid.present? || logingov_uuid.present? }
  validates :logingov_uuid, presence: true, unless: -> { idme_uuid.present? || sec_id.present? }

  before_validation :initialize_uuid, on: :create

  attr_readonly :uuid

  scope :idme_uuid_match, lambda { |v|
                            if v.present?
                              where(idme_uuid: v)
                            else
                              none
                            end
                          }
  scope :sec_id_match, lambda { |v|
                         if v.present?
                           where(sec_id: v)
                         else
                           none
                         end
                       }
  scope :logingov_uuid_match, lambda { |v|
                                if v.present?
                                  where(logingov_uuid: v)
                                else
                                  none
                                end
                              }

  private

  def initialize_uuid
    new_uuid  = generate_uuid
    new_uuid  = generate_uuid until unique?(new_uuid)
    self.uuid = new_uuid
  end

  def unique?(new_uuid)
    return true unless Account.exists?(uuid: new_uuid)
  end

  def generate_uuid
    SecureRandom.uuid
  end
end
