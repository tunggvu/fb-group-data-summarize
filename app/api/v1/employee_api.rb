# frozen_string_literal: true

class V1::EmployeeAPI < Grape::API
  resource :employees do
    before { authenticate! }

    desc "Get information of all employees"
    params do
      optional :query, type: String
      optional :organization_id, type: Integer
      optional :skill_id, type: Integer
    end
    get do
      employees = Employee.ransack(
        name_or_employee_code_cont: params[:query],
        organization_id_eq: params[:organization_id],
        levels_skill_id_eq: params[:skill_id]
        ).result(distinct: true)
      present employees, with: Entities::Employee
    end

    desc "Create employee"
    params do
      requires :name, type: String, allow_blank: false
      requires :employee_code, type: String, allow_blank: false
      requires :email, type: String, allow_blank: false
      requires :password, type: String, allow_blank: false
      optional :organization_id, type: Integer
      optional :birthday, type: DateTime
      optional :phone, type: String
    end
    post do
      authorize :organization, :executive?, policy_class: EmployeePolicy
      present Employee.create!(declared(params).to_h), with: Entities::Employee
    end

    route_param :id do
      before do
        @employee = Employee.find params[:id]
      end

      desc "Get employee's information"
      get do
        present @employee, with: Entities::Employee
      end

      desc "Delete employee"
      delete do
        authorize @employee, :executive?
        @employee.destroy!
        { message: I18n.t("delete_success") }
      end
    end
  end
end
