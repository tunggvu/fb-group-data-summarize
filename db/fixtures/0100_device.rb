# frozen_string_literal: true

Device.device_types.keys.each do |type|
  20.times do |n|
    project = Project.all.sample
    Device.seed do |d|
      d.name = "#{type} #{n}"
      d.serial_code = Faker::Code.imei
      d.device_type = type
      d.project = project
      d.os_version = Faker::Name.name
      d.pic = project.employees.sample
    end
  end
end
