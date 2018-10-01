# frozen_string_literal: true

class Request < ApplicationRecord
  attr_reader :confirmation_token

  enum status: { pending: 1, approved: 2, rejected: 3 }
  enum request_type: { assign: 1, borrow: 2 }

  belongs_to :device
  belongs_to :project
  belongs_to :request_pic, class_name: Employee.name
  belongs_to :requester, class_name: Employee.name

  validates :request_type, presence: true
  validate :valid_pic?, :change_owner?, :can_update_pic?

  before_create :generate_confirmation_digest, if: :pending?

  class << self
    def new_token
      SecureRandom.urlsafe_base64
    end

    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
  end

  def authenticate?(token)
    return false unless confirmation_digest
    BCrypt::Password.new(confirmation_digest).is_password?(token)
  end

  def update_request_link(status)
    ENV["HOST_DOMAIN"] + "/requests/#{id}/#{status}?confirmation_token=#{confirmation_token}"
  end

  private

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
end
