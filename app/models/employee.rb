# frozen_string_literal: true

class Employee < ApplicationRecord
  belongs_to :organization, optional: true

  has_many :employee_levels, dependent: :destroy
  has_many :projects, dependent: :nullify, foreign_key: :product_owner_id
  has_many :levels, through: :employee_levels
  has_one :employee_token, dependent: :destroy
  validates :name, presence: true
  validates :employee_code, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: Settings.validations.email_regex }

  scope :of_organizations, -> (org_ids) { where(organization_id: org_ids).ids }

  has_secure_password validations: false

  def is_manager?(organization)
    orgs = []
    # TODO: Fix here. Avoid using loop to find parent organizations
    loop do
      break unless organization.present?
      orgs << organization
      organization = organization.parent
    end
    orgs.pluck(:manager_id).include? self.id
  end

  Organization.levels.keys.each do |role|
    define_method "is_higher_#{role}_manager_of?" do |org|
      is_manager?(org) && Organization.levels[role] >= org.level_before_type_cast &&
        Organization.levels[role] <= Organization.levels[organization.level]
    end
  end

  Organization.levels.keys.each do |role|
    define_method "is_higher_or_equal_#{role}_manager!" do
      Organization.levels[self.organization.level] >= Organization.levels[role]
    end
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
