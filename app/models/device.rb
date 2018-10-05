# frozen_string_literal: true

class Device < ApplicationRecord
  enum device_type: { laptop: 1, pc: 2, mac_mini: 3, mac_book: 4 }

  before_create :assign_to_po
  after_create :create_first_request

  belongs_to :project
  belongs_to :pic, class_name: Employee.name, optional: true

  has_many :requests, -> { order(id: :desc) }

  validates :name, presence: true
  validates :serial_code, presence: true
  validates :device_type, presence: true
  validates :project_id, presence: true

  private

  def assign_to_po
    self.pic = project.product_owner
  end

  def create_first_request
    po = project.product_owner
    requests.create!(
      status: Request.statuses[:confirmed],
      project_id: project_id,
      request_pic: po,
      requester: po,
      modified_date: Time.current
    )
  end
end
