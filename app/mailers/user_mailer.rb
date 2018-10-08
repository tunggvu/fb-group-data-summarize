# frozen_string_literal: true
require "sendgrid-ruby"

class UserMailer < ApplicationMailer
  class << self
    def send_device_request(request)
      data = {
        personalizations: [personalizations_object(request)],
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

    def personalizations_object(request)
      requester = request.requester
      device = request.device
      recipient = (request.pending? ? device.project.product_owner : request.request_pic)
      target_request = (request.pending? ? "device_borrow" : "device_assignment")
      accept_status = (request.pending? ? "approve" : "confirm")
      {
        to: [
          {
            email: recipient.email,
            name: recipient.name
          }
        ],
        dynamic_template_data: {
          "title": I18n.t("email.#{target_request}.title"),
          "announcement":
            I18n.t("email.#{target_request}.announcement",
            requester: requester.name, device: device.name, project: request.project.name),
          "accept_link": request.update_request_link("#{accept_status}"),
          "reject_link": request.update_request_link("reject"),
          "accept_btn": I18n.t("email.#{target_request}.confirm"),
          "reject_btn": I18n.t("email.#{target_request}.reject")
        }
      }
    end
  end
end
