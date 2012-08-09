# Provides utility functions for doing authorization on CRUD and other operations
# to the model, given a standard way of getting the current user and
# a list of users and roles for an object.
# Note: requires the model to implement the authorizing_objects method

# FIXME: Properly deal with anonymous users - or are we not allowing
# anonymous usage?

module AuthorizedModel
  # Given an account
  def lookup_abilities(role)
    role_to_ability = {
      'admin' => ['create', 'edit', 'delete']
    }
    return role_to_ability[role] || [role]
  end

  # Get a list of all abilities that that person has on an object
  def abilities(person)
    if !person
      return Set.new
    elsif person.is_superuser
      return Set.new(['all'])
    end
    person_roles = person.object_people

    # Get the list of all objects that might allow authorization
    # Get the ancestors for this object
    # Get the intersection of the two lists to determine
    # what roles are available on this object for the account
    auth_objects = self.authorizing_objects

    #person_roles.each do |pr|
    #  puts "PR: #{pr.inspect}"
    #end
    #auth_objects.each do |ao|
    #  puts "AO: #{ao.inspect}"
    #end

    object_roles = Set.new()

    person_roles.each do |pr|
      if auth_objects.include? pr.personable
        object_roles.add(pr.role)
      end
    end

    # Iterate through all of the roles and look up the
    # allowed abilities
    abilities = Set.new
    object_roles.each do |role|
      abilities.merge(lookup_abilities(role))
    end
    abilities
  end

  def allowed?(ability, user = nil, &block)
    # Get the abilities from the current user on this object
    # See if the ability is in the set - if so, return true
    # otherwise return false.

    if !user
      user = Authorization.current_user
    end

    ability_list = abilities(user)

    if ability_list.include?(ability) || ability_list.include?('all')
      if block_given?
        yield
      end
      true
    else
      false
    end
  end

  # Add implicit authorization checks to standard CRUD operations
  # on the model.

  # FIXME: For operations that aren't on an existing object
  # (e.g. create), perform a different check.
end
