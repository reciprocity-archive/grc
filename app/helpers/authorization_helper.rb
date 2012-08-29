module AuthorizationHelper
  def allowed_objs(objects, ability)
    # FIXME: Until we audit all of the controllers/roles
    # to determine object visibility, allow all objects to
    # be seen for all abilities.
    objects
    #objects.reduce([]) do |filtered, object|
    #  object.allowed?(ability, @current_user) do
    #    filtered.append(object)
    #  end
    #  filtered
    #end
  end
end
