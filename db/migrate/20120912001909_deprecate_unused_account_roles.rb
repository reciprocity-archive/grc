class DeprecateUnusedAccountRoles < ActiveRecord::Migration
  class Account < ActiveRecord::Base
  end

  def up
    Account.where(:role => :admin).each do |account|
      account.role = :superuser
      account.save
    end

    Account.where(:role => :admin).each do |account|
      account.role = :superuser
      account.save
    end

    Account.where(:role => :analyst).each do |account|
      account.role = :user
      account.save
    end

    Account.where(:role => :guest).each do |account|
      account.role = :user
      account.save
    end
  end

  def down
  end
end
