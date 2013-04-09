
Deploying to a Heroku instance
==============================

Prepare
-------

Make sure you have completed the steps in [Setting up Heroku](heroku_setup.html) before proceeding.  This document assumes you have an active Heroku instance and need only update it.

### Gather information

You need the following information:

- `<heroku-appname>`: The name you specified (or Heroku generated) for your application.
- `<heroku-remote>`: The "git-remote" corresponding to your Heroku instance, such as `heroku`.
- `<environment>`: The value of `RAILS_ENV` and `RACK_ENV`, such as `staging`.
- `<local-branch>`: The branch you wish to deploy, such as `staging`.

Deploy
------

#### Push your changes

Push the git branch.  Heroku will automatically install any changes to `Gemfile`.  On the first push, this will take 10 minutes or more.

    git push <heroku-remote> <local-branch>:master

#### Confirm Rails environment variables

Make sure the environment is configured correctly.  Do not use `production`, unless you're certain you intend it, as this will trigger delivery of emails and other external effects.

Check the current environment by finding the `RACK_ENV` and `RAILS_ENV` variables in the output of this command:

    heroku config --app <heroku-appname>

To change it, or just to make sure, you can set the `RACK_ENV` and `RAILS_ENV` environment variables:

    heroku config:add --app <heroku-appname> \
        RAILS_ENV=<environment> \
        RACK_ENV=<environment>

#### Prepare database

If this is a new deployment:

    heroku run rake db:reset --app <heroku-appname>

(If this is a new deployment with demo data, use `demo:reset`.)

If this is an existing deployment, migrate any pending database changes:

    heroku run rake db:migrate --app <heroku-appname>

#### Restart

(This may not be necessary, but occasionally is.)

    heroku restart --app <heroku-appname>

#### Check it out

Generally, you can check `<heroku-appname>.herokuapp.com` to see the application live.


### Heroku Tips

#### Console

To get a Rails console in a Heroku instance, use:

    heroku run console --app <heroku-appname>

#### Logs

To see the recent logs on a Heroku application, use:

    heroku logs --app <heroku-appname>

To 'follow' the log output (ala `tail -f`) use the `-t` switch:

    heroku logs -t --app <heroku-appname>


