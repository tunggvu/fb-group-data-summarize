# frozen_string_literal: true

class Device < ApplicationRecord
  enum device_type: { laptop: 1, pc: 2, mac_mini: 3, mac_book: 4 }

  before_create :update_po_create
  after_create :create_first_request

  belongs_to :project
  belongs_to :pic, class_name: Employee.name, optional: true

  has_many :requests

  validates :name, presence: true
  validates :serial_code, presence: true
  validates :device_type, presence: true
  validates :project_id, presence: true

  private
  def update_po_create
    self.pic = project.product_owner
  end

  def create_first_request
    requests.create!(
      status: Request.statuses[:approved],
      project_id: project_id,
      request_pic: project.product_owner,
      requester: project.product_owner,
      modified_date: Time.current
    )
  end
end
