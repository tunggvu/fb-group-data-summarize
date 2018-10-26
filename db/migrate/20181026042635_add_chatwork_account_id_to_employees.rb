class AddChatworkAccountIdToEmployees < ActiveRecord::Migration[5.2]
  def change
    add_column :employees, :chatwork_account_id, :string
  end
end
