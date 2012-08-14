# Authorization notes

# THIS IS OUT OF DATE. Update this!

Authorization will be built on top of CanCan, a gem for Rails
authorization (https://github.com/ryanb/cancan)

## Concepts

CanCan uses the basic concept of abilities, with basic calls as such:

    if (can? ability, object)

In the case of our system, whether the ability is allowed or not is determined by determining whether
one of the authorization_scopes for the user allows the user to perform the action.

Authorization scopes apply to a heirarchical tree of a node and all of its child nodes,
OR potentially node/person relationships (such as Owner). Authorization scopes include a role, which determines
broad permissions on the node. In addition(?), authorization scopes can include
additional filters on node properties that allow you to further restrict the scope
of the nodes that you are allowed to modify.

## New Model

All authorization should be able to be encapsulated in a single table that represents
the authorization scopes.

    authorization_scope
        belongs_to :user
        belongs_to :scopeable, :polymorphic => true # May need to change for ownership scope
        # role
        # filters (TBD, may not be necessary)


## Permissions

Types of actions that we want to restrict

* create
* read
* update
* delete
* link * this is a bit more complicated, since linking affects scopes.
* modify_scape

## Roles

Specific sets of permissions

* Superadmin - All permissions on all objects.

* Admin - Admin roles allow for all actions, except for linking

* Editors - Editors differ from admins in that they are not allowed to modify
scope rules, or modify users.

* Viewer - View users are only allowed to view subsets of data. There may be additional
    filters

## Authorization psuedocode
Basic authorization mechanics for authorization of a node

* Use authentication system to determine the user
* Use decl_auth to request permission to perform an action on an node (e.g. update)
* Find all scope rules for a user
* Find all parents for the node.
* See if any scope rules apply to the parent of a user
* See if permissions on the role allow the action.
* Apply any additional filters associated with the authorization scope

## ToDos

* Figure out if we can do scope by ownership in addition to scope by node.


## Notes

Note: creating relationships vs. acls.
Compliance managers will invite auditors to join an audit.

class Section
    def auditors:
        AuthScope.where(:role_type => 'auditor',
                        :object_type => @class_name)
    end

Might be able to edit company, but not regulatory even though company may parent regulatory

comp control -> Reg section -> reg control

Paper Trail for previous versions, diffs
Edit/commit log

Edit -> approve workflow, approve relationships

Approvals?
Listeners/notifications?

Declarative authorizations
--------------------------

    authorization do
        role :section_auditor do
            has_permission_on :sections, :to => :edit do
                if_attribute :auditors => contains {user}
            end

            has_permission_on :control, :to => :read do
            end

        has_permission_on :controls, :to => :manage do
          if_permitted_to :manage, :section
          # instead of
          #if_attribute :branch => {:managers => contains {user}}
        end
      end
    end
