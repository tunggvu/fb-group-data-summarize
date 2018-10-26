# frozen_string_literal: true

class Employee < ApplicationRecord
  include AASM

  enum chatwork_status: { off: 0, on: 1, pending: 2 }

  belongs_to :organization, optional: true

  has_many :employee_levels, dependent: :destroy
  has_many :levels, through: :employee_levels
  has_many :efforts, through: :employee_levels
  has_many :total_efforts, dependent: :destroy
  has_many :skills, through: :levels
  has_many :devices, foreign_key: :pic_id
  has_many :requests, foreign_key: :requester_id
  has_many :sprints, through: :efforts
  has_many :projects_effort, -> { distinct }, through: :sprints, foreign_key: :project_id, source: :project

  has_one :employee_token, dependent: :destroy

  validates :name, presence: true
  validates :employee_code, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: Settings.validations.email_regex }
  validates :phone, allow_nil: true, format: { with: Settings.validations.phone_regex }

  #TODO: refactor using transaction later:
  after_create :init_total_effort

  scope :of_organizations, -> (org_ids) { where organization_id: org_ids }

  scope :with_total_efforts_in_period, ->(start_time, end_time) do
    eager_load(:total_efforts).where("start_time <= ? and end_time >= ?", end_time, start_time)
  end

  scope :with_total_efforts_lt, ->(total_effort_lt) { group(:id).having('max("value") < ?', total_effort_lt) if total_effort_lt.present? }

  scope :with_total_efforts_gt, ->(total_effort_gt) { group(:id).having('max("value") > ?', total_effort_gt) if total_effort_gt.present? }

  has_secure_password validations: false

  mount_base64_uploader :avatar, ImageUploader

  aasm column: :chatwork_status, enum: true, whiny_transitions: false do
    state :off, initial: true
    state :on, :pending

    event :change_mode_from_off do
      transitions from: :off, to: :on, if: :existed_room?
      transitions from: :off, to: :pending, unless: :existed_room?
    end

    event :change_mode_from_on do
      transitions from: :on, to: :off
    end

    event :change_mode_from_pending do
      transitions from: :pending, to: :off, unless: :existed_room?
      transitions from: :pending, to: :on, if: :existed_room?
    end
  end

  def existed_room?
    chatwork_room_id.present?
  end

  def is_manager?(organization)
    organization.level_before_type_cast > 1 && organization.path.pluck(:manager_id).include?(self.id)
  end

  def init_total_effort
    TotalEffort.create(employee_id: id, start_time: Date.today, end_time: "31/12/9999", value: 0)
  end

  def role
    return "ADMIN" if is_admin?
    return "EMPLOYEE" unless Organization.find_by(manager_id: id)

    roles = {
      Organization.levels[:division] => "DIVISION_MANAGER",
      Organization.levels[:section] => "SECTION_MANAGER",
      Organization.levels[:clan] => "GROUP_LEADER",
      Organization.levels[:team] => "TEAM_LEADER"
    }
    key = organization.level_before_type_cast

    roles[key]
  end

  def projects
    sql = "(#{owned_projects.to_sql}) UNION (#{projects_effort.to_sql})"
    Project.from("(#{sql}) projects")
  end

  def is_other_product_owner?(params_project)
    owned_projects.present? && !owned_projects.include?(params_project)
  end

  def owned_organizations
    return Organization.all if is_admin?
    root_org = Organization.find_by(manager: self)
    root_org ? Organization.subtree_of(root_org) : []
  end

  def owned_projects
    is_admin? ? Project.all : Project.where(product_owner: self)
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
