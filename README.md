# Compliance Management System

## Objectives

* Map multiple requirements to a a single control
* Auto-generate compliance reports formatted for each regulator or auditor
* Provide real time status reporting on compliance state
* Automate control execution, auditing, and process management where possible
* Provide a systematic means to keep compliance data fresh

## Requirements

CMS uses the following third-party software:

* Ruby 1.9
* Rails 3
* DataMapper for object persistence
* HAML for view templates
* Prawn for PDF manipulation
* Yard for documentation

## Features:

* Keep track of compliance objects, including: regulations in a structured format, standardized control objectives, company controls, systems, source documents
* The system will group controls required to meet certain compliance targets (e.g. regulations)
Risk:Control objective mapping
* The system will create reports on the compliance status of controls and targets. Reports will be organized based on tags, groups and status.

Planned:

* Versioning of regulations, controls, etc, including an audit trail of changes

## Administration Features:

* RBAC - role based access control. The system will authenticate users, internal and, optionally, external. A role system will restrict access to controls, administrative actions and reports. The UI will adjust based on the role of the user. Different workflow will be available for different roles.
* Bulk actions on compliance objects.
* Orphan detection for unowned objects.
* Archive section for obsolete compliance objects.

## Architecture:

* The frontend will is a web application.
* The backend will be modular with a plugin system allowing interfacing with internal systems for acquisition of evidence and control status.

## Testing

    rspec spec

and autotesting (runs tests as files change):

    spork &
    autotest -v
