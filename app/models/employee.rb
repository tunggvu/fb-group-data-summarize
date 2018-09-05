# frozen_string_literal: true

class Employee < ApplicationRecord
  belongs_to :organization, optional: true

  has_many :employee_levels, dependent: :destroy
  has_many :projects, dependent: :nullify, foreign_key: :product_owner_id
  has_many :levels, through: :employee_levels
  has_many :efforts, through: :employee_levels
  has_many :total_efforts
  has_one :employee_token, dependent: :destroy

  validates :name, presence: true
  validates :employee_code, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: Settings.validations.email_regex }
  validates :phone, allow_nil: true, format: { with: Settings.validations.phone_regex }

  scope :of_organizations, -> (org_ids) { where organization_id: org_ids }

  has_secure_password validations: false

  mount_base64_uploader :avatar, ImageUploader

  def is_manager?(organization)
    organization.level_before_type_cast > 1 && organization.path.pluck(:manager_id).include?(self.id)
  end

  class << self
    def authenticate!(email, password)
      employee = Employee.find_by email: email
      unless employee.try :authenticate, password
        raise APIError::WrongEmailPassword
      end
      employee
    end
  end
end
