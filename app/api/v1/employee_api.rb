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
      optional :project_id, type: Integer
      optional :start_time, type: Date
      optional :end_time, type: Date
      optional :total_effort_lt, type: Integer
      optional :ids, type: Array[Integer]
    end

    get do
      allowed_keys_for_employee = [:organization_id, :organization_not_in]
      params.slice!(*allowed_keys_for_employee) unless policy(:employee).executive?

      search_params = {
        name_or_employee_code_cont: params[:query],
        levels_skill_id_eq: params[:skill_id],
        levels_id_in: params[:level_ids],
        id_in: params[:ids],
        efforts_sprint_project_id_eq: params[:project_id]
      }
      search_params[:organization_id_not_in] =
        Organization.subtree_of(Organization.find(params[:organization_not_in])).ids if params[:organization_not_in]
      search_params[:organization_id_in] =
        Organization.subtree_of(Organization.find(params[:organization_id])).ids if params[:organization_id]

      employees = Employee.ransack(search_params).result(distinct: true)

      if params[:start_time] && params[:end_time]
        employee_efforts = employees.with_total_efforts_in_period(params[:start_time], params[:end_time])
        employees = if params[:total_effort_lt]
                      emp_ids = employee_efforts.with_total_efforts_max_values(params[:total_effort_lt]).select(:id)
                      employee_efforts.where(id: emp_ids)
                    else
                      employee_efforts
                    end

        present paginate(employees.includes(:total_efforts)), with: Entities::EmployeeEffort

      elsif params[:start_time].present? ^ params[:end_time].present?
        raise_errors I18n.t("api_error.empty_params", params: "input_time"),
          Settings.error_formatter.http_code.validation_errors
      else
        present paginate(employees), with: Entities::Employee
      end
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

      resource :efforts do
        params do
          requires :start_time, type: Date, allow_blank: false
          requires :end_time, type: Date, allow_blank: false
        end
        get do
          effort_detail = @employee.efforts.relate_to_period(params[:start_time], params[:end_time])
          effort_detail.includes(sprint: :project).each { |effort| authorize effort.project, :view? }
          present effort_detail.includes(sprint: :project, employee_level: [level: :skill]), with: Entities::EffortDetailWithProject
        end
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
