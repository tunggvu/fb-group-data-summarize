# frozen_string_literal: true

class Employee < ApplicationRecord
  belongs_to :organization, optional: true

  has_many :employee_skills, dependent: :destroy
  has_many :projects, dependent: :nullify, foreign_key: :product_owner_id
  has_many :employee_roles, dependent: :destroy
  has_many :skills, through: :employee_skills
  has_many :roles, through: :employee_roles
  has_one :employee_token, dependent: :destroy
  validates :name, presence: true
  validates :employee_code, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: Settings.validations.email_regex }

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
