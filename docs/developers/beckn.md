---
id: beckn
title: Enabling Beckn
sidebar_label: Enabling Beckn
---

## Introduction

This documentation provides a comprehensive guide to integrating the Beckn protocol into the Pupilfirst learning management system (LMS).

**Beckn Protocol** is an open standard designed to enable universal connectivity and transaction interoperability across various domains and platforms.
Originally conceived for the mobility sector to allow seamless interactions between service providers and consumers, Beckn's flexible architecture supports a wide range of services, including education, healthcare, logistics, and more.

In the context of education, the Beckn protocol facilitates the discovery, enrollment, and management of educational services, such as courses, training sessions, and workshops. By integrating Beckn, educational platforms can become part of a broader network, enabling them to be discovered by a wide array of consumer applications (BAPs - Beckn Application Platforms). This not only increases the visibility of educational offerings but also streamlines the transaction process, making it easier for students to find and enroll in courses that match their needs.

### Key Components of the Beckn Architecture

![image](https://github.com/pupilfirst/pupilfirst/assets/14979190/59de2f77-53e0-49f7-a292-8c881b7fe38b)

The Beckn protocol facilitates a network layer that allows various service providers (BPPs) and consumers facing apps (BAPs) to interact through a standardized set of APIs. In the context of Pupilfirst, our system acts as a BPP, allowing our courses to be discovered and utilized by various BAPs.

### Components

![image](https://github.com/pupilfirst/pupilfirst/assets/14979190/316072f9-87f9-46c7-9ce4-a9e7dab5628c)

- **BAP (Beckn Application Platform)**: These are the platforms through which users (students, educators) interact. A BAP could be an educational portal or a mobile app that allows users to search for and enroll in courses offered by various BPPs through the Beckn network.
- **Backend Protocol Server**: Splits into a client-facing and a network-facing component that acts as a bridge between the BAP, network and BPP. (We use beckn-onix for this purpose)
- **BPP (Beckn Provider Platform)**: BPP is typically an LMS (Learning Management System) like Pupilfirst. It offers various educational services, such as online courses, and is configured to respond to requests from BAPs. When integrated with Beckn, the LMS can respond to searches, handle enrollments, and update course details dynamically.

The LMS (Pupilfirst) acts as a BPP, offering courses that can be discovered and enrolled in through the Beckn network. The Beckn protocol defines a set of APIs that the LMS must implement to interact with the network and respond to requests from BAPs.

The response format follows the [DSEP Protocol Specification](https://github.com/beckn/DSEP-Specification/blob/draft/api/dsep.yaml). Example requests and responses are available in the [beckn-sandbox](https://github.com/beckn/beckn-sandbox/tree/main/src/dsep/courses-training/) repository.

Use the [swagger editor](https://editor.swagger.io/) to view the Beckn protocol API documentation.

## Changes specific to Pupilfirst

#### Search

- Supports `provider` and `descriptor` filters, which correspond to `school` and `course name` respectively.
- If no filters are provided, the search will return all Beckn-enabled courses.

#### Confirm

- The student will be enrolled in the default cohort.
- A one-time login token will be generated and included in the response.

#### Update

- The update endpoint only supports updating the student name.

#### Cancel

- The cancel request will mark the student as `dropped_out`.

# Production Setup

## Prerequisites

Before enabling Beckn in your Pupilfirst instance, ensure you have:

- A Protocol Gateway that supports the Beckn protocol and its endpoints.
- A domain pointed at the LMS instance for receiving Beckn requests and `BECKN_DOMAIN` set in the environment (required only when multi-tenancy is enabled).
  > The Beckn webhook URL will be `https://<BECKN_DOMAIN>/inbound_webhooks/beckn`

## Environment Variables

Set the following environment variables:

```bash
# Domain configured for Beckn API.
BECKN_DOMAIN=your_beckn_webhook_domain

# Optional: webhook authentication, 256-bit key.
BECKN_WEBHOOK_HMAC_KEY=your_beckn_webhook_hmac_key

# Beckn Credentials
BECKN_BPP_ID=beckn_bpp_id
BECKN_BPP_URI=beckn_bpp_uri
BECKN_BPP_CLIENT_URI=beckn_bpp_client_uri
```

> **Note:** If you are using authentication for webhook, update the `default.yml` file of BPP client:

```yml
useHMACForWebhook: true
sharedKeyForWebhookHMAC: your_beckn_webhook_hmac_key
```

## Configuration

Use the following steps to enable Beckn in your school and courses. These commands are to be run in the Rails console.
You can access the Rails console by running `bundle exec rails c` in the terminal.

### Set Email Address for School

You will also need to set an email address for the school to comply with the protocol. This email address will be shared with the BAPs and students as part of support information.

You can set it as part of school strings. Run the following command to set the email address for the school:

```bash
school = School.find(school_id)
school.school_strings.where(key: "email_address").first_or_create!(value: "your_email_address")
```

### Enable Beckn for a School

You can enable Beckn for a school by setting the `beckn_enabled` attribute to `true` in the school model.

```ruby
school = School.find(school_id)
school.update!(beckn_enabled: true)
```

Making `beckn_enabled: false` will disable Beckn for the school.

### Enable Beckn for a Course

You can enable Beckn for a course by setting the `beckn_enabled` attribute to `true` in the course model.

```ruby
course = Course.find(course_id)
course.update!(beckn_enabled: true)
```

Making `beckn_enabled: false` will disable Beckn for the course.

### Set Default Currency

Use the school configurations doc to set the default currency for a school.

# Development Setup

This guide provides detailed instructions for setting up a local development environment to test Beckn integration in Pupilfirst. We will use setup a BPP protocol server with beckn-onix and expose it the beckn open collective registry. We can use Postman to mimic a BAP requests for development.

Make sure you have a docker environment set up on your machine.

## Local Tunnel Setup

The BPP protocol server needs to be exposed to the internet for the Beckn registry to send requests.
We will use a [localtunnel](https://github.com/localtunnel/localtunnel) to expose the network component of the protocol server running on port 6002. (You will setup at the Protocol server after the tunnel is running.)

### Install tunnel globally

```bash
npm install -g localtunnel
```

### Run the tunnel

```bash
lt --port 6002 --subdomain=bpp-bodhi
```

Customize the subdomain to your preference. The tunnel will be running on `https://bpp-bodhi.loca.lt`.

## Beckn Onix Protocol Server Setup

The protocol server consists of two components: the network and the client. The network component is responsible for handling requests from the Beckn registry, while the client component is responsible for handling requests from and to the BBP.

Beckn Onix is a tool that helps set up the protocol server in a few simple steps. Refer to the [detailed docs if you want to learn more.](https://github.com/beckn/beckn-onix/blob/main/docs/setup_walkthrough.md#create-a-new-network-and-install-the-registry).

```bash
git clone https://github.com/beckn/beckn-onix.git
cd beckn-onix/install
./beckn-onix.sh
```

```
What would you like to do?: 1 (Join an existing network)
Which platform would you like to set up?: 3 (BPP)
Enter BPP Subscriber ID: bpp-bodhi-pf (This is the BECKN_BPP_ID, you can set it to any value)
Enter BPP Subscriber URL: https://bpp-bodhi.loca.lt (This is the BECKN_BPP_URI, you can set it to any value)
Enter the registry_url: https://registry.becknprotocol.io/subscribers
Enter Webhook URL: http://host.docker.internal:3000/inbound_webhooks/beckn (Make sure the port is same as the one you are running the server on)
```

> Linux users should use `172.17.0.1` instead of `host.docker.internal` in the webhook URL. If you are in WSL, use `host.docker.internal`.

## Monitoring Protocol Server Logs

Monitor logs for the protocol server network and client in two terminal windows.

```bash
# Terminal 1
docker logs -f bpp-client
# Terminal 2
docker logs -f bpp-network
```

## Enable access to transact on the registry

The BPP needs to be subscribed to the registry to receive requests. This is controlled by the registry owners, even tho beckn-onix will will create the subscription, it will be in the initiated state, the registry owners need to change it to subscribed for the BPP to receive requests.

To enable access to transact on the registry, you need to contact the Beckn team through the discord channel. Easy shortcut is to reach out to `vbabu75` in the Beckn discord (use DSEP related channel / DM).

## Postman Collection Setup for Local Testing

You will need a BAP to test the end to end flow, as quick hack we can use Postman to mimic the BAP requests.

Import the offical [beckn-sandbox](https://github.com/beckn/beckn-sandbox/blob/main/artefacts/DSEP/dsep-services-sandbox.postman_collection.json) collection to Postman and update the variables to point to the local server.

Update the following variables in the collection:

```
bpp_uri: https://bpp-bodhi.loca.lt
bpp_id: bpp-bodhi-pf
```

## Layer2 Config Setup

A layer 2 config is required by the Beckn protocol to validate the schema of the Beckn messages. The layer2 config should be created in the network and client components of the protocol server.

Create a layer2 config in the network and client. The file name should correspond to the domain you are using.

Examples:

- For the domain `dsep:courses`, the file name should be `dsep_courses_1.1.0.yaml`. The version number should match the core schema version.
- For the domain `open-belem:courses`, the file name should be `open-belem_courses_1.1.0.yaml`.

```
# Create layer2 config in network
docker exec -it bpp-network sh
cd cd schemas/
cp core_1.1.0.yaml dsep_courses_1.1.0.yaml
```

```
# Create layer2 config in client
docker exec -it bpp-client sh
cd cd schemas/
cp core_1.1.0.yaml dsep_courses_1.1.0.yaml
```

We should create a new file for each domain we are using in the Beckn protocol.

## Pupilfirst Environment Variables Setup

```bash
# If you have multi-tenancy enabled, set the domain to the one you are using.
# Ignore this variable if multi-tenancy is disabled in development.
BECKN_DOMAIN=beckn.localhost

# Optional: webhook authentication, 256-bit key.
BECKN_WEBHOOK_HMAC_KEY=your_beckn_webhook_hmac_key

# Beckn Credentials
BECKN_BPP_ID=bpp-bodhi-pf
BECKN_BPP_URI=https://bpp-bodhi.loca.lt
BECKN_BPP_CLIENT_URI=http://localhost:6001
```

> **Note:** If you are using authentication for webhook, update the `default.yml` file of BPP client:

```yml
useHMACForWebhook: true
sharedKeyForWebhookHMAC: your_beckn_webhook_hmac_key
```

## Server Start

Ensure the server is running on the same port as the one set in the webhook URL.

Requests will be sent to the server on the `/inbound_webhooks/beckn` endpoint, handled by the `InboundWebhooks::BecknController`. All requests through the Beckn protocol will be asynchronous and handled by the `InboundWebhooks::ProcessBecknRequestJob`.

## Common Issues

### Cache on the Registry

It may take some time for the registry to update the BPP state from initiated to subscribed. If you do not receive a request for `on_search`, try another request like `on_init` or `on_select`.

### Invalid Credentials

If setting up beckn-onix for the first time, the setup might fail to add `==` to the end of the credentials. The private key should end with `==` and the public key with `=`.

> Logs might show `Error: invalid input`. This issue has been observed on macOS but may occur on other OS as well.

```bash
# Enter the container
docker exec -it bpp-client sh
vi config/default.yml
# Update the keys by adding `==` to the end of the private key and `=` to the end of the public key.
# In VI, press `i` to enter insert mode, `esc` to exit insert mode, and `:wq` to save and exit.
# Restart the container
docker restart bpp-client
# Repeat the same for bpp-network
docker exec -it bpp-network sh
....
```
