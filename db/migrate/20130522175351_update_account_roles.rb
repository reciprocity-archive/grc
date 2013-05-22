class UpdateAccountRoles < ActiveRecord::Migration
  def up
    Account.where(:role => 'superuser').each do |account|
      account.role = 'admin'
      account.save
    end
  end

  def down
  end
end
