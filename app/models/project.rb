# frozen_string_literal: true

class Project < ApplicationRecord
  belongs_to :product_owner, class_name: Employee.name

  has_many :phases, -> { order(starts_on: :desc) }, dependent: :destroy
  has_many :sprints, dependent: :destroy
  has_many :efforts, through: :sprints
  has_many :employee_levels, through: :efforts
  has_many :employees, -> { distinct }, through: :employee_levels
  has_many :devices

  validates :name, presence: true

  mount_base64_uploader :logo, ImageUploader

  def current_sprint
    sprints.where("starts_on <= :time AND ends_on >= :time", {time: Time.zone.now}).first
  end
end
