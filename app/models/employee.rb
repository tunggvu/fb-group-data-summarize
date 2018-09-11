# frozen_string_literal: true

class Employee < ApplicationRecord
  belongs_to :organization, optional: true

  has_many :employee_levels, dependent: :destroy
  has_many :projects, dependent: :nullify, foreign_key: :product_owner_id
  has_many :levels, through: :employee_levels
  has_many :efforts, through: :employee_levels
  has_many :total_efforts, dependent: :destroy
  has_many :skills, through: :levels

  has_one :employee_token, dependent: :destroy

  validates :name, presence: true
  validates :employee_code, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: Settings.validations.email_regex }
  validates :phone, allow_nil: true, format: { with: Settings.validations.phone_regex }

  #TODO: refactor using transaction later:
  after_create :init_total_effort

  scope :of_organizations, -> (org_ids) { where organization_id: org_ids }

  scope :with_total_efforts_in_period, ->(start_time, end_time) do
    joins(:total_efforts).where("start_time < ? and end_time > ?", end_time, start_time)
  end

  scope :with_total_efforts_max_values, ->(total_effort_lt) { group(:id).having('max("value") < ?', total_effort_lt) }

  has_secure_password validations: false

  mount_base64_uploader :avatar, ImageUploader

  def is_manager?(organization)
    organization.level_before_type_cast > 1 && organization.path.pluck(:manager_id).include?(self.id)
  end

  def init_total_effort
    TotalEffort.create(employee_id: id, start_time: Date.today, end_time: "31/12/9999", value: 0)
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
