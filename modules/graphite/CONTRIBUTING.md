Contributing
------------

normal

  1. [Fork](http://help.github.com/forking/) puppet-TEMPLATE
  2. Create a topic branch against the develop branch `git checkout develop; git checkout -b my_branch`
  3. Push to your branch `git push origin my_branch`
  4. Create a [Pull Request](http://help.github.com/pull-requests/) from your branch against the develop branch

[git-flow](https://github.com/nvie/gitflow)

  1. [Fork](http://help.github.com/forking/) puppet-TEMPLATE
  2. Create a feature `git flow feature start my-feature`
  3. Publish your featue `git flow feature publish my-feature`
  4. Create a [Pull Request](http://help.github.com/pull-requests/) from your branch against the develop branch

Testing
-------

Tests are written with [rspec-puppet](http://rspec-puppet.com/). CI is covered by [Travis CI](http://about.travis-ci.org/) and the current status is visible [here](http://travis-ci.org/echocat/puppet-TEMPLATE).

To run all tests:

    bundle exec rake validate && bundle exec rake lint && bundle exec rake spec SPEC_OPTS='--color --format documentation'


Branching
---------

This repository is organized and maintained with the help of [gitflow](https://github.com/nvie/gitflow). Developers are encouraged to use it when working with this repository.

We use the following naming convention for branches:

* develop (during development)
* master (will be or has been released)
* feature/<name> (feature branches)
* release/<name> (release branches)
* hotfix/<name> (hotfix branches)
* (empty version prefix)

During development, you should work in feature branches instead of committing to master directly. Tell gitflow that you want to start working on a feature and it will do the work for you (like creating a branch prefixed with feature/):

    git flow feature start <FEATURE_NAME>

The work in a feature branch should be kept close to the original problem. Tell gitflow that a feature is finished and it will merge it into master and push it to the upstream repository:

    git flow feature finish <FEATURE_NAME>

Even before a feature is finished, you might want to make your branch available to other developers. You can do that by publishing it, which will push it to the upstream repository:

    git flow feature publish <FEATURE_NAME>

To track a feature that is located in the upstream repository and not yet present locally, invoke the following command:

    git flow feature track <FEATURE_NAME>

Changes that should go into production should come from the up-to-date master branch. Enter the "release to production" phase by running:

    git flow release start <VERSION_NUMBER>

In this phase, only meta information should be touched, like bumping the version and update the history. Finish the release phase with:

    git flow release finish <VERSION_NUMBER>

Versioning
----------

This project is versioned with the help of the [Semantic Versioning Specification](http://semver.org/) using 0.0.1 as the initial version. Please make sure you have read the guidelines before increasing a version number either for a release or a hotfix.
