---
id: beckn
title: Enabling Beckn
sidebar_label: Enabling Beckn
---

## Introduction

Pupilfirst supports the Beckn protocol for enabling commerce. This document explains how to enable Beckn in your Pupilfirst instance.

## Prerequisites

Before you can enable Beckn in your Pupilfirst instance, you need to have the following:

- A Protocol Gateway that supports the Beckn protocol and its endpoints.
- A domain pointed at LMS instance for recieving Beckn requests and `BECKN_DOMAIN` set in the environment. (Only required when multi-tenancy is enabled)

## Set the following environment variables

```bash
# Beckn BPP ID configured in the Protocol Gateway
BECKN_BPP_ID=beckn_bpp_id
# Url of the Protocol Server Network
BECKN_BPP_URI=beckn_bpp_uri
# Url of the Protocol Server Client
BECKN_BPP_CLIENT_URI=beckn_bpp_client_uri
```
