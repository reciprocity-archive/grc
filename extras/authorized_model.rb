# Provides utility functions for doing authorization on CRUD and other operations
# to the model, given a standard way of getting the current user and
# a list of users and roles for an object.
# Note: requires the model to implement the authorizing_objects method

# FIXME: Properly deal with anonymous users - or are we not allowing
# anonymous usage?

module AuthorizedModel
  def allowed?(ability, account_or_person = nil, &block)
    Authorization::allowed?(ability, account_or_person, self, &block)
  end

  # Add implicit authorization checks to standard CRUD operations
  # on the model.

  # FIXME: For operations that aren't on an existing object
  # (e.g. create), perform a different check.
end
