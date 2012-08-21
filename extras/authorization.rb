# A lot of this is cribbed from how declarative_authorization handles
# model-based authorization.
module Authorization
  # Controller-independent method for retrieving the current user.
  # Needed for model security where the current controller is not available.
  def self.current_account
    Thread.current["current_account"]
  end

  # Controller-independent method for setting the current user.
  def self.current_account=(account)
    Thread.current["current_account"] = account
  end

  # Primarily for use by the console and tests, where we don't
  # necessarily want to use authorization.
  class SuperUser
    def superuser?
      true
    end
  end

  def self.lookup_abilities(role)
    role = role.to_sym
    # FIXME: Some of these roles are NOT meant to be used globally (e.g. owner).
    # Should we add some more enforcement?
    role_to_ability = {
      :superuser => [:all],
      :admin => [:create, :read, :update, :delete],
      :compliance_analyst => [:read, :update, :delete],# Same as owner
      :user => [],

      # Non-global roles
      :owner => [:read, :edit, :delete]
    }
    return role_to_ability[role] || [role]
  end

  # Get a list of all abilities that a role gives
  def self.abilities_from_roles(roles)
    # Iterate through all of the roles and look up the
    # allowed abilities
    abilities = Set.new
    roles.each do |role|
      abilities.add(role) # Role name is also an ability
      abilities.merge(lookup_abilities(role))
    end
    abilities
  end

  # Given an account and/or object
  def self.roles(account_or_person = nil, object = nil)
    roles = Set.new

    if !account_or_person
      account_or_person = Authorization.current_account
    end

    # If you have an account, turn it into a person
    if account_or_person
      if (account_or_person.class == Account)
        # FIXME: In the future this will come from a separate table, and there
        # could be more than one.
        account = account_or_person
        person = account.person

        # FIXME: whitelist account roles to the accepted list.
        roles.add(account.role.to_sym)
      elsif account_or_person.class == Person
        person = account_or_person
      end
    end

    # Okay, at this point we should have a person.
    if person
      object_roles = person.object_people

      # Get the list of all objects that might allow authorization
      # Get the ancestors for this object
      # Get the intersection of the two lists to determine
      # what roles are available on this object for the account
      if (object)
        auth_objects = object.authorizing_objects
      else
        auth_objects = []
      end

      object_roles.each do |object_role|
        if auth_objects.include? object_role.personable
          roles.add(object_role.role.to_sym)
        end
      end
    end

    roles
  end

  # Get a list of all abilities that a role gives
  def self.abilities_from_roles(roles)
    # Iterate through all of the roles and look up the
    # allowed abilities
    abilities = Set.new
    roles.each do |role|
      abilities.add(role)
      abilities.merge(lookup_abilities(role))
    end

    abilities
  end

  def self.abilities(account_or_person, object)
    roles = roles(account_or_person, object)
    return abilities_from_roles(roles)
  end

  def self.allowed?(ability, account_or_person, object, &block)
    ability = ability.to_sym

    ability_list = Authorization::abilities(account_or_person, object)
    if ability_list.include?(ability) || ability_list.include?(:all)
      if block_given?
        yield
      end
      true
    else
      false
    end
  end
end
