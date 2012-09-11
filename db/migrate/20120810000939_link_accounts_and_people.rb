class LinkAccountsAndPeople < ActiveRecord::Migration
  # This migration does a few different things:
  # Adds an association between accounts and people
  # Renames the username attribute to email in people
  # Links accounts to people via e-mail, creating people
  # as necessary to map to accounts.

  # Local models so that migration is safe
  class Account < ActiveRecord::Base
    belongs_to :person
  end

  class Person < ActiveRecord::Base
  end

  def up
    add_column :accounts, :person_id, :integer
    rename_column :people, :username, :email

    Account.reset_column_information
    Person.reset_column_information

    Person.all.each do |person|
      if !(person.email =~ /.+@.+/)
        puts "Updating e-mail for #{person.email}"
        # add @google.com to the e-mail
        person.email = person.email + '@google.com'
        person.save
      else
        puts "Person e-mail is correct for #{person.email}"
      end
    end

    Account.all.each do |account|
      person = Person.find_by_email(account.email)
      if person
        # A person exists with the e-mail, create the relationship
        puts "Associating #{account.inspect} with #{person.inspect}"
      else
        # No person exists with the e-mail, create an associated person
        person = Person.create({:email => account.email}, :without_protection => true)
        puts "Associating #{account.inspect} with NEW person #{person.inspect}"
      end
      account.person = person
      account.save
    end
  end

  def down
    # Not fully reversing it (can't undo the e-mail changes), but better than nothing
    remove_column :accounts, :person_id, :integer
    rename_column :people, :email, :username
  end
end
