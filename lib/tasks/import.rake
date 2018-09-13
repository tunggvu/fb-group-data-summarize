# frozen_string_literal: true

require "csv"
require "activerecord-import"

namespace :data_preparation do

  desc "Import users from CSV"
  task import_div1_employees: :environment do
    filename = File.join Rails.root, "public", "uploads", "Div 1 member list.csv"
    division = Organization.create_with(level: "division").find_or_create_by name: "Division 1"
    sections = division.children
    employees = []
    employee_levels = []

    CSV.foreach(filename, headers: true).with_index do |row, i|
      name = row["Name"]
      name = name.index("(") ? name[0, name.index("(") - 1] : name
      email = name_to_email name
      employee_code = "B1210#{(i + 1).to_s.rjust(3, "0")}"

      org = row["Group"].split("-")
      section = sections.create_with(level: "section").find_or_create_by name: org[0].gsub("SEC", "Section ")
      group = section.children.create_with(level: "clan").find_or_create_by name: org[1].gsub("G", "Clan ")

      employee = Employee.new name: name, email: email, employee_code: employee_code, organization: group
      employee.id = Employee.find_by(email: email).try(:id)
      skill = Skill.find_or_create_by(name: row["Skill"]) do |created_skill|
        created_skill.levels.build name: "Junior", rank: 1
      end

      employee_level = EmployeeLevel.find_or_initialize_by employee: employee, level: skill.levels.last
      employees << employee
      employee_levels << employee_level
    end

    Employee.import! employees, on_duplicate_key_update: [:name, :employee_code, :organization_id]
    EmployeeLevel.import! employee_levels, on_duplicate_key_ignore: true
    puts "Import success"
  end

  def name_to_email(name)
    email = name.squish
    email.slice!(email.rindex(" ")) if email.split.last.length == 1
    email = email.tr(
      "àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ",
      "aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyydAAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD"
    ).gsub(" ", ".").downcase
    email + "@framgia.com"
  end
end
