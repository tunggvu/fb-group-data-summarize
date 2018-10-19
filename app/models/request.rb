# frozen_string_literal: true

class Request < ApplicationRecord
  include AASM

  attr_reader :confirmation_token

  enum status: { pending: 1, confirmed: 2, approved: 3, rejected: 4 }

  belongs_to :device
  belongs_to :project
  belongs_to :request_pic, class_name: Employee.name
  belongs_to :requester, class_name: Employee.name

  validate :valid_pic?, unless: :rejected?
  validate :change_owner?, unless: :rejected?
  validate :can_update_pic?, if: proc { !persisted? && approved? }
  validate :can_borrow_device?, if: :pending?

  before_create :generate_confirmation_digest
  after_create :send_request_email, unless: :confirmed?

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

    authenticator = Proc.new { |token| authenticate(token) }
    before_all_events Proc.new { self.modified_date = Date.current }

    event :approve, before: authenticator, success: :send_request_email do
      transitions from: :pending, to: :approved
    end

    event :confirm, before: authenticator, success: :update_related_info do
      transitions from: :approved, to: :confirmed
    end

    event :reject, before: authenticator do
      transitions from: :approved, to: :rejected
      transitions from: :pending, to: :rejected
    end

    event :reject_without_token do
      transitions from: :approved, to: :rejected
      transitions from: :pending, to: :rejected
    end
  end

  def update_request_link(status)
    ENV["FRONTEND_HOST"] + "/requests/#{id}/#{status}?confirmation_token=#{confirmation_token}"
  end

  private

  def send_request_email
    return if ENV["SEND_EMAIL"].try(:upcase) == "FALSE"

    if Rails.env.development? || Rails.env.test?
      UserMailer.send_device_request_to_mailcatcher(self).deliver
    else
      UserMailer.send_device_request(self)
    end
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

  def can_borrow_device?
    return if requester.is_admin? || requester.owned_projects.include?(project)
    errors.add :base, I18n.t("models.request.device_unchangeable")
  end

  def update_related_info
    update_device_info
    reject_other_requests
  end

  def update_device_info
    device.update! pic: request_pic, project: project
  end

  def reject_other_requests
    device.requests.includes(:device, :request_pic, :requester, project: :product_owner).where(status: [:pending, :approved]).each do |request|
      request.reject_without_token!
    end
  end

  def authenticate(token)
    if confirmation_digest && BCrypt::Password.new(confirmation_digest).is_password?(token)
      self.confirmation_digest = pending? ? generate_confirmation_digest : nil
    else
      raise APIError::InvalidEmailToken
    end
  end
end
