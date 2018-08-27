# frozen_string_literal: true

class V1::EmployeeAPI < Grape::API
  resource :employees do
    before { authenticate! }

    desc "Get information of all employees"
    paginate per_page: Settings.paginate.per_page.employee
    params do
      optional :query, type: String
      optional :organization_id, type: Integer
      optional :skill_id, type: Integer
      optional :organization_not_in, type: Integer
      optional :level_ids, type: Array[Integer]
    end

    get do
      search_params = {
        name_or_employee_code_cont: params[:query],
        levels_skill_id_eq: params[:skill_id],
        levels_id_in: params[:level_ids]
      }
      search_params[:organization_id_not_in] =
        Organization.subtree_of(Organization.find(params[:organization_not_in])).ids if params[:organization_not_in]
      search_params[:organization_id_in] =
        Organization.subtree_of(Organization.find(params[:organization_id])).ids if params[:organization_id]

      employees = Employee.ransack(search_params).result(distinct: true)
      present paginate(employees), with: Entities::Employee
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
