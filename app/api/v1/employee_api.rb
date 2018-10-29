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
      optional :total_effort_gt, type: Integer
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
        employees = if params[:total_effort_lt] || params[:total_effort_gt]
                      emp_ids = employee_efforts.with_total_efforts_lt(params[:total_effort_lt])
                                                .with_total_efforts_gt(params[:total_effort_gt])
                                                .select(:id)
                      employee_efforts.where(id: emp_ids)
                    else
                      employee_efforts
                    end

        present paginate(employees), with: Entities::EmployeeEffort

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

      resource :requests do
        before do
          authorize @employee, :self_or_subordinate?
        end

        desc "Get device requests that created by employee"
        paginate per_page: Settings.paginate.per_page.request
        get :created do
          requests = @employee.created_requests.includes(:project, :request_pic, :requester)
            .order(id: :desc)
          present paginate(requests), with: Entities::Request
        end

        desc "Get device requests that requested for employee"
        paginate per_page: Settings.paginate.per_page.request
        get :received do
          requests = @employee.received_requests.includes(:project, :request_pic, :requester)
            .order(id: :desc)
          present paginate(requests), with: Entities::Request
        end

        desc "Get device requests that need handle by employee"
        paginate per_page: Settings.paginate.per_page.request
        get :handle do
          requests = @employee.requests_need_handle
          present paginate(requests), with: Entities::Request
        end
      end

      resource :efforts do
        desc "Get all effort details of employee in a time range"
        params do
          requires :start_time, type: Date, allow_blank: false
          requires :end_time, type: Date, allow_blank: false
          optional :skill_id, type: Integer
          optional :project_id, type: Integer
          optional :organization_id, type: Integer
        end
        get do
          search_params = {
            employee_level_level_skill_id_eq: params[:skill_id],
            employee_level_employee_organization_id_eq: params[:organization_id],
            sprint_project_id_eq: params[:project_id]
          }

          effort_ids = Effort.relate_to_period(params[:start_time], params[:end_time]).ransack(search_params).result(distinct: true).select(:id)
          effort_detail = @employee.efforts.where(id: effort_ids)
          effort_detail.includes(sprint: :project).each { |effort| authorize effort.project, :view? }
          present effort_detail.includes(sprint: :project, employee_level: [level: :skill]), with: Entities::EffortDetailWithProject
        end
      end

      resource :skills do
        desc "Get employees's skills"
        get do
          present @employee, with: Entities::EmployeeSkill, employee_id: @employee.id
        end
      end

      desc "Get employee's information"
      get do
        employee = Employee.includes(levels: :skill, devices: :project).find params[:id]
        present employee, with: Entities::EmployeeDetail
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
