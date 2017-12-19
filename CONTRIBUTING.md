# Contributing
A roadmap of this project is located at https://github.com/Icinga/puppet-icinga2/milestones. Please consider
this roadmap when you start contributing to the project.

Before starting your work on this module, you should [fork the project] to your GitHub account. This allows you to
freely experiment with your changes. When your changes are complete, submit a [pull request]. All pull requests will be
reviewed and merged if they suit some general guidelines:

* Changes are located in a topic branch
* For new functionality, proper tests are written
* Changes should not solve certain problems on special environments
* Your change does not handle third party software for which dedicated Puppet modules exist
  * such as creating databases, installing webserver etc.

## Branches
Choosing a proper name for a branch helps us identify its purpose and possibly find an associated bug or feature.
Generally a branch name should include a topic such as `fix` or `feature` followed by a description and an issue number
if applicable. Branches should have only changes relevant to a specific issue.

```
git checkout -b fix/service-template-typo-1234
git checkout -b feature/config-handling-1235
```

## Testing
Classes and defined types are unit tested with [RSpec]. For integration tests we use [Serverspec]. When modifying
existing classes or types, make sure all existing tests pass. If you add new functionality, make sure to write appropriate
tests as well. A complete guide on how to run tests is described in [TESTING.md].


[fork the project]: https://help.github.com/articles/fork-a-repo/
[pull request]: https://help.github.com/articles/using-pull-requests/
[RSpec]: http://rspec-puppet.com/
[Serverspec]: http://serverspec.org/
[TESTING.md]: TESTING.md
