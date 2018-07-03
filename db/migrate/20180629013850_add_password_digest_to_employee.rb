# frozen_string_literal: true

class AddPasswordDigestToEmployee < ActiveRecord::Migration[5.2]
  def change
    add_column :employees, :password_digest, :string
  end
end
