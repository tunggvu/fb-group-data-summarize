# frozen_string_literal: true
require "sendgrid-ruby"

class UserMailer < ApplicationMailer
  class << self
    def send_device_assignment_request(request)
      requester = request.requester
      request_pic = request.request_pic
      device = request.device
      data = {
        personalizations: [
          {
            to: [
              {
                email: Rails.env.production? ? request_pic.email : ENV["DEFAULT_EMAIL_TO"],
                name: request_pic.name
              }
            ],
            dynamic_template_data: {
              "title": I18n.t("email.device_assignment.title"),
              "announcement":
                I18n.t("email.device_assignment.announcement", requester: requester.name, device: device.name),
              "accept_link": request.update_request_link("confirm"),
              "reject_link": request.update_request_link("reject"),
              "accept_btn": I18n.t("email.device_assignment.confirm"),
              "reject_btn": I18n.t("email.device_assignment.reject")
            }
          }
        ],
        from: {
          email: ENV["DEFAULT_EMAIL_FROM"]
        },
        template_id: Settings.template.device_assignment.id,
      }
      send_mail(data)
    end

    def send_mail(data)
      # TODO: đẩy master.key lên server
      sg = SendGrid::API.new(api_key: ENV["SENDGRID_API_KEY"] || "")
      response = sg.client.mail._("send").post(request_body: data)
      # TODO: bắt lỗi đầy đủ của Sengrid, custom dưới dạng 6xx
      raise APIError::SendEmailError if response.status_code == "400"
    end
  end
end
