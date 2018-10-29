# frozen_string_literal: true

class Skill < ApplicationRecord
  has_many :levels, dependent: :destroy
  validates :name, presence: true, uniqueness: true

  accepts_nested_attributes_for :levels, allow_destroy: true

  mount_base64_uploader :logo, ImageUploader
end
