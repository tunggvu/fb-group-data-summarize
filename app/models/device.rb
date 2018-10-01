# frozen_string_literal: true

class Device < ApplicationRecord
  enum device_type: { laptop: 1, pc: 2, mac_mini: 3, mac_book: 4 }

  before_create :update_po_create
  after_create :create_first_request
  after_create :send_assignment_request, unless: :po_take_charge?

  belongs_to :project
  belongs_to :pic, class_name: Employee.name, optional: true

  has_many :requests, -> { order(id: :desc) }

  validates :name, presence: true
  validates :serial_code, presence: true
  validates :device_type, presence: true
  validates :project_id, presence: true

  private

  attr_reader :request_pic

  def update_po_create
    @request_pic = pic
    self.pic = project.product_owner
  end

  def create_first_request
    po = project.product_owner
    requests.create!(
      status: Request.statuses[:approved],
      project_id: project_id,
      request_pic: po,
      requester: po,
      modified_date: Time.current
    )
  end

  def send_assignment_request
    request = requests.create!(
      status: Request.statuses[:pending],
      project_id: project_id,
      request_pic: request_pic,
      requester: project.product_owner,
      modified_date: Time.current
    )
    UserMailer.send_device_assignment_request(request)
  end

  def po_take_charge?
    !request_pic || request_pic == project.product_owner
  end
end
