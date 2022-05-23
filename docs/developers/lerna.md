---
id: lerna
title: Using Lerna to publish packages
sidebar_label: Using Lerna
---

Pupilfirst LMS is a [monorepo](https://en.wikipedia.org/wiki/Monorepo), that contains the main web application and other
libraries we've developed. [Lerna](https://github.com/lerna/lerna) is the tool that we use to manage this multi-package
repository.

## Steps

1. Update the library.
2. Commit your work, but **do not push to Github.**
3. Use `changed` command to verify changes to packages.
4. Use `version` command to amend last commit.
5. Use `publish` command to publish updated packages to npmjs.com.
6. Push latest commits to Github.

## Details

When you're done making changes to a library, you can commit your changes as usual. **DO NOT push changes to Github
yet**.

Once that's done, check for packages that Lerna can publish new versions of:

    yarn run lerna changed

This command will show all the packages that have changed since the last release. You can also use the `diff` command to
see the _diff_ between current version and the last published version.

Once you've confirmed the changes, you can use the `version` command to amend the last commit, to include version bumps.

    yarn run lerna version --amend

This command will ask you how to change the version of changed packages. It'll then update the last commit, changing
versions as per your instruction and also tagging the commit.

Once the commit is ready, you can use it to publish updated packages to npmjs.com. If you haven't logged into npmjs.com
prior to this, you'll need to login with the `npm login` command before publishing.

    yarn run lerna publish from-git

This command will read the version info from the repo, and publish packages.

Don't forget to push the commit to Github as well!

## Why use the _version_ command?

Why bother with `version`? Why not just run `publish` and allow it to set the version?

Running `publish [bump]` after committing your changes will cause lerna to create a _new_ commit which includes the
version bump and the git tags. Using the `version` command allows us to avoid this extra commit which lets the git
history be just a little bit less noisy.
