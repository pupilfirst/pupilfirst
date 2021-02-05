---
id: documentation
title: Documentation
sidebar_label: Documentation
---

The source of [docs.pupilfirst.com](https://docs.pupilfirst.com) is stored in the `/docs` folder in our Github repo, and
is managed using [docsify](https://docsify.js.org/).

The source of [developers.pupilfirst.com](https://developers.pupilfirst.com) (_this_ website) is stored in the `/docs/developers` folder
in our Github repo, and is managed using [Docusaurus](https://v2.docusaurus.io/).

## Developer documentation

Simply navigate to the `docs/developers` folder and run the `start` command:

    cd docs/developers
    yarn run start

This should launch the developer documentation in your browser.

## Feature documentation

First, install the docsify CLI globally:

    npm i docsify-cli -g

Then serve the `docs` folder on the desired port.

    docsify serve docs -p 3010i

The `-p` option sets the port. Visit `localhost:PORT` to view docs locally.
