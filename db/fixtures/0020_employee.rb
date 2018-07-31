# frozen_string_literal: true

Employee.seed do |e|
  e.name = "Administator"
  e.email = "admin@framgia.com"
  e.password = "Aa@123456"
  e.employee_code = "B1210000"
  e.is_admin = true
  e.avatar = "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png"
  e.phone = "0987654321"
end

n = 0
# Seed manager for organizations
Organization.all.each do |org|
  employee = Employee.seed do |e|
    e.name = Faker::Name.name
    e.email = "#{e.to_hash["name"].gsub(" ", ".").downcase}@framgia.com"
    e.employee_code = "B1210#{(n += 1).to_s.rjust(3, "0")}"
    e.password = "Aa@123456"
    e.organization = org
    e.avatar = "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png"
    e.phone = "0987654321"
  end
  org.update_attributes manager_id: employee.last.id
end

Organization.team.each do |org|
  5.times do
    Employee.seed do |e|
      e.name = Faker::Name.name
      e.email = "#{e.to_hash["name"].gsub(" ", ".").downcase}@framgia.com"
      e.employee_code = "B1210#{(n += 1).to_s.rjust(3, "0")}"
      e.password = "Aa@123456"
      e.organization = org
      e.avatar = "https://cdn3.iconfinder.com/data/icons/avatars-15/64/_Ninja-2-512.png"
      e.phone = "0987654321"
    end
  end
end
