# frozen_string_literal: true

class User < ApplicationRecord
  has_one :user_token, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  has_secure_password validations: false

  mount_base64_uploader :avatar, ImageUploader

  class << self
    def authenticate!(email, password)
      user = User.find_by email: email
      unless user.try :authenticate, password
        raise APIError::WrongEmailPassword
      end
      user
    end
  end
end
