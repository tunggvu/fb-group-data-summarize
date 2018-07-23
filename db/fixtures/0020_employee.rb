# frozen_string_literal: true

n = 0
# Seed manager for organizations
Organization.all.each do |org|
  Employee.seed do |e|
    e.id = org.id
    e.name = Faker::Name.name
    e.email = "#{e.to_hash["name"].gsub(" ", ".").downcase}@framgia.com"
    e.employee_code = "B1210#{(n += 1).to_s.rjust(3, "0")}"
    e.password = "Aa@123456"
    e.organization = org
    org.update_attributes manager_id: e.to_hash["id"]
  end
end

Organization.team.each do |org|
  5.times do
    Employee.seed do |e|
      e.name = Faker::Name.name
      e.email = "#{e.to_hash["name"].gsub(" ", ".").downcase}@framgia.com"
      e.employee_code = "B1210#{(n += 1).to_s.rjust(3, "0")}"
      e.password = "Aa@123456"
      e.organization = org
    end
  end
end
