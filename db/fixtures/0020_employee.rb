# frozen_string_literal: true

Employee.seed do |e|
  e.id = 1
  e.name = "Admin"
  e.email = "admin@framgia.com"
  e.employee_code = "B120000"
  e.organization_id = 1
  e.is_admin = true
end

Employee.seed do |e|
  e.id = 2
  e.name = "Vu Xuan Dung"
  e.email = "vu.xuan.dung@framgia.com"
  e.employee_code = "B120001"
  e.organization_id = 1
end

Employee.seed do |e|
  e.id = 3
  e.name = "Tran Van Tan"
  e.email = "tran.van.tan@framgia.com"
  e.employee_code = "B120002"
  e.organization_id = 2
end

Employee.seed do |e|
  e.id = 4
  e.name = "Tran Ngoc Thang"
  e.email = "tran.ngoc.thang@framgia.com"
  e.employee_code = "B120003"
  e.organization_id = 3
end

Employee.seed do |e|
  e.id = 5
  e.name = "Tran Thai Hoc"
  e.email = "tran.thai.hoc@framgia.com"
  e.employee_code = "B120004"
  e.organization_id = 4
end

10.times do |n|
  Employee.seed do |e|
    e.name = "Employee #{n+1}"
    e.email = "employee#{n+1}@framgia.com"
    e.employee_code = "B12100#{n}"
    e.organization = Organization.last
  end
end
