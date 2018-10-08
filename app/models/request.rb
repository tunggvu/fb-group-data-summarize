# frozen_string_literal: true

class Request < ApplicationRecord
  include AASM

  attr_reader :confirmation_token

  enum status: { pending: 1, confirmed: 2, approved: 3, rejected: 4 }

  belongs_to :device
  belongs_to :project
  belongs_to :request_pic, class_name: Employee.name
  belongs_to :requester, class_name: Employee.name

  validate :valid_pic?, :change_owner?, :can_update_pic?

  before_create :generate_confirmation_digest
  after_create :send_request_email, if: proc { request_pic != project.product_owner }

  class << self
    def new_token
      SecureRandom.urlsafe_base64
    end

    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
  end

  aasm column: :status, enum: true, whiny_transitions: false do
    state :pending, initial: true
    state :approved, :confirmed, :rejected

    before_all_events Proc.new { |token| authenticate(token) }

    event :approve do
      transitions from: :pending, to: :approved
    end

    event :confirm, success: :update_device_pic do
      transitions from: :approved, to: :confirmed
    end

    event :reject do
      transitions from: :approved, to: :rejected
      transitions from: :pending, to: :rejected
    end
  end

  def update_request_link(status)
    ENV["HOST_DOMAIN"] + "/requests/#{id}/#{status}?confirmation_token=#{confirmation_token}"
  end

  private

  def send_request_email
    return if ENV["SEND_EMAIL"].try(:upcase) == "FALSE"
    UserMailer.send_device_assignment_request(self)
  end

  def generate_confirmation_digest
    @confirmation_token = Request.new_token
    self.confirmation_digest = Request.digest(confirmation_token)
  end

  def valid_pic?
    return if project.product_owner == request_pic || project.employees.include?(request_pic)
    errors.add :person_in_charge, I18n.t("models.request.pic_in_project")
  end

  def change_owner?
    return if device.requests.count == 0
    return if request_pic != device.pic || project != device.project
    errors.add :base, I18n.t("models.request.device_nothing_change")
  end

  def can_update_pic?
    return if requester.is_admin?
    project_of_device = device.project
    return if requester == device.pic && project == project_of_device &&
      project.employees.include?(requester)
    return if requester == project_of_device.product_owner && requester == project.product_owner
    errors.add :base, I18n.t("models.request.device_unchangeable")
  end

  def update_device_pic
    device.update! pic: request_pic
  end

  def authenticate(token)
    return false unless confirmation_digest

    if BCrypt::Password.new(confirmation_digest).is_password?(token)
      self.confirmation_digest = nil
    else
      raise APIError::InvalidEmailToken
    end
  end
end
