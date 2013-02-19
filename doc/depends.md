GRC Dependencies
================

Gems used by GRC
----------------

[rails ~> 3.1.1](http://rubyonrails.org/)
    Ruby on Rails is the framework used by GRC for rapid application development.

[gdata/gdata-ruby-util/gdata_19](https://github.com/tokumine/GData)
    [Original gdata-ruby-util](http://code.google.com/p/gdata-ruby-util/)
    GData is the (deprecated?) gem for Google API interactions.  It has been replaced by gdata-ruby-util, which is incompatiable with Ruby 1.9.x.  `gdata_19` is the patched version.

[authlogic](https://github.com/binarylogic/authlogic)
    Authlogic is used for authentication and session management.

[acl9](https://github.com/be9/acl9)
    Acl9 provides access control list functionality to protect certain routes from unauthorized access.

[haml](http://haml-lang.com/)
    [haml-rails](https://github.com/indirect/haml-rails)
    HAML provides an alternative markup language to construct HTML in views.  HAML-rails is the adapter to use HAML with Rails.

[sass](http://sass-lang.com/)
    SASS provides an alternative CSS syntax and generates the CSS for requests.

[bcrypt-ruby](http://bcrypt-ruby.rubyforge.org/)
    `bcrypt-ruby` provides a binding for the bcrypt() library, and is used for hashing for user passwords.

[prawn](http://prawn.majesticseacreature.com/)
    Prawn provides PDF document generation.

[paper_trail](https://github.com/airblade/paper_trail
    PaperTrail is used to track object history for audits.

[builder](http://rubydoc.info/gems/builder/3.0.0/frames)
    [Homepage](http://onestepback.org/)
    Builder is used for generating XML, and is required by Rails.

[psych](https://github.com/tenderlove/psych)
    Psych provides YAML import/export; included to work around an issue with migrations.

[thinking-sphinx](http://pat.github.com/ts/en/)
    Thinking Sphinx handles interaction with a locally running Sphinx full-text search service.

[encrypted-cookie-store](https://github.com/hmcfletch/encrypted-cookie-store)
    Encrypts session cookies.

[strict-forgery-protection](https://github.com/ratnikov/strict-forgery-protection)
    Detects CSRF vulnerabilities by monitoring database queries during requests.

[awesome-nested-set](https://github.com/collectiveidea/awesome_nested_set)
    Awesome Nested Set provides an API and optimized SQL queries for representing hierarchies in SQL.

[validation-scopes](https://github.com/stevehodgkiss/validation-scopes)
    Validation Scopes provides non-constraining ActiveRecord validations and error objects, e.g. warnings.


### Gems used only in development

[yard](http://yardoc.org/)
    Yard simplifies documentation generation.

[redcarpet](https://github.com/tanoku/redcarpet)
    Redcarpet is a Markdown parser


Client-side libraries used by GRC
---------------------------------

For client-side interaction, GRC uses JQuery, JQuery-UI, and several plugins for these frameworks.

* [JQuery](http://jquery.com/)
* [JQuery-UI](http://jqueryui.com/)

Plugins and addons to the JQuery system:

* [jquery-ujs](https://github.com/rails/jquery-ujs)
    jquery-ujs is included by default in Rails 3.  It is used for simple form-handling and interaction between JS and Ruby code.
* [jquery.cookie](https://github.com/carhartl/jquery-cookie)
    Utilities for reading and writing cookies on the client-side.

* Multi-select plugins:
    The following plugins are used for improving the UI of multi-select elements.
    - [jquery.manyselect](http://www.erichynds.com/jquery/jquery-ui-manyselect-widget/)
    - [jquery.multiselect](http://www.erichynds.com/jquery/jquery-ui-multiselect-widget/)
    - [jquery.multiselect.filter](http://www.erichynds.com/jquery/jquery-ui-multiselect-widget/)


