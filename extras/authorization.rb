# A lot of this is cribbed from how declarative_authorization handles
# model-based authorization.
module Authorization
  # Controller-independent method for retrieving the current user.
  # Needed for model security where the current controller is not available.

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
      :user => [],
      :reader => [:read]
    }
    return role_to_ability[role] || [role]
  end

  # Given an account and/or object
  def self.roles(account = nil)
    # This returns roles associated SPECIFICALLY with an account.
    roles = Set.new
    roles.add(account.role.to_sym)
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

  def self.allowed?(ability, account_or_person, object, &block)
    # Do basic account-level authorization through baked account roles.
    # i.e., if your account type gives you abilities, check those first.
    account_abilities = Set.new
    if (account_or_person.class == Account)
      account_abilities = abilities_from_roles(roles(account_or_person))
      person = account_or_person.person
    else
      person = account_or_person
    end
    ability = ability.to_sym

    # Note: In the case of much of our tests, we don't have a person, just
    # a passed in role. Hence the person && in the if statement below.
    if ((account_abilities.include? :all) ||
        (account_abilities.include? ability) ||
        (person && person.object_via_ability?(object, ability)))
      if block_given?
        yield
      end
      true
    else
      false
    end
  end

  def self.allowed_objects(ability, account_or_person, objects)
    # Do basic account-level authorization through baked account roles.
    # i.e., if your account type gives you abilities, check those first.
    account_abilities = Set.new
    if (account_or_person.class == Account)
      account_abilities = abilities_from_roles(roles(account_or_person))
      person = account_or_person.person
    else
      person = account_or_person
    end

    ability = ability.to_sym

    # If you've got magical account level abilities and you have that ability,
    # assume that you're allowed to do it on all of the objects.
    # FIXME: Think through this logic for cases which are not :all.
    if account_abilities.include?(:all) || account_abilities.include?(ability)
      return objects
    end

    # If you don't have a magic account, figure out what you're allowed to see via
    # the graph traversal.
    return person.objects_via_ability(objects, ability)
  end
end
