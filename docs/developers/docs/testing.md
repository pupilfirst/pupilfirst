---
id: testing
title: Automated Testing
sidebar_label: Testing
---

The default settings expect Google Chrome to be installed to be able to run tests. To execute all tests, run:

    bundle exec rspec

You can choose which browser the specs run in, using the `JAVASCRIPT_DRIVER` environment variable. Check the
`spec/rails_helper.rb` file for its possible options.

## Generating coverage report

To generate spec coverage report, run:

    COVERAGE=true bundle exec rspec

This will generate coverage report as HTML within the `/coverage` directory.
