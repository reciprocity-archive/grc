
Setting up Heroku
=================

**Note:** In the commands below:

  * any occurences of "`<...>`" should be replaced with appropriate values!
  * any lines ending with "``\``" should be combined with the next line


First-time setup
----------------

If you have not yet setup Heroku gems and keys, read the following:

### Important Heroku notes

If you'll only be working with a single Heroku account and application, you can apply the `heroku` commands below as written.  However, if you have multiple accounts or multiple applications, you should use these hints:

#### Multiple accounts

Install the [heroku-accounts](https://github.com/ddollar/heroku-accounts) gem.

#### Multiple applications

Be sure to use `--app <application-name>` with every `heroku` command (except `heroku create`).


Heroku
------

#### Gather information

To setup the Heroku instance, you'll need the following information, and to replace occurences in commands with the correct value.

If you are setting up an individual development instance, these values are your choice.

- `<heroku-appname>`:
- `<heroku-remote>`:

#### Create the app

This creates using the "Cedar" stack, with 'heroku-candidate' as the git-remote.

    heroku create <heroku-appname> --stack cedar --remote <heroku-remote>

**Note:** If you are using the `heroku-accounts` gem, you *must* use `--account <account-name>` here, as in:

    heroku create <heroku-appname> --stack cedar --account <your-account> --remote <heroku-remote>

Ensure the app was created by seeing `<heroku-appname>` in the output of:

    heroku apps

You should see something like:

    <heroku-appname>    user@domain.com


#### Configure environment variables

##### Set rack and rails environment variables (if not using default `production`):

    heroku config:add --app <heroku-appname> \
        RAILS_ENV=candidate \
        RACK_ENV=candidate


Deploy
------

See [Deploying to a Heroku instance](heroku_deployment.html)


