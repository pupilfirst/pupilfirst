# DPG readiness: email provider independence plan

**Status:** Implementation on feature branch; live SMTP and bounce-event evidence is still pending.
**Target:** Pupilfirst LMS, from `master` commit `001ec461da8042f94d31288931a434898fc29a2a`.
**Scope:** DPGA indicator 4 (platform independence), outbound transactional email and suppression only.
**Decision:** Retain Postmark as the default; use Rails Action Mailer SMTP as the open, swappable transport. Do not change mailers or the job queue.

## Why

Production previously fixed `config.action_mailer.delivery_method = :postmark`.
Email is critical for login, reset, enrollment, reviews and account deletion.
The Postmark webhook also records permanent delivery failures in a global
`BounceReport` table; `SchoolMailer`, sign-in, GraphQL reset and enrollment
consult that table. The Dockerfile precompiles Rails assets under
`RAILS_ENV=production` without a Postmark token, so credentials must not
become a build-time requirement.

The DPG Standard does **not** require removing the existing provider. The
evidence goal is to show an independent alternative that works without
significant changes to the core product, including necessary operational
safeguards. Implementation alone is not DPGA approval.

## Implemented on this branch

### Change set A: standard Rails delivery selection

- `MAIL_DELIVERY_METHOD` defaults to `postmark` (existing behavior).
- `smtp` uses `config.action_mailer.smtp_settings` with mandatory STARTTLS,
  strict required variables, port validation and optional authenticated SMTP.
- Supported authentication: plain/login/cram_md5; SMTP credentials optional
  together for a secured internal relay.
- No automatic provider fallback after delivery errors. No extra gem or schema.
- No change to `deliver_later`, Delayed Job, mail templates, or per-school
  sender signature logic.
- Preserve Postmark's non-fetch token lookup so Docker assets can compile
  without a token. Credentials remain runtime secrets, not Docker build args.

### Change set B: bounce persistence decoupled from Postmark

- `EmailBounces::RecordService.call(email:, type:)` supports only
  `HardBounce` and `SpamComplaint`.
- Use `create_or_find_by!` keyed only by normalized email, backed by existing
  unique `citext` index. First event wins and duplicate webhook deliveries
  are idempotent under normal concurrent insert races.
- Existing authenticated Postmark webhook calls the service.
- Global suppression behavior is intentionally unchanged; it is not per school.
- No public generic webhook is exposed. A particular independent SMTP server's
  permanent-bounce and complaint events still need a properly authenticated,
  tested adapter. Temporary failures must never be marked as permanent.

## Deployment contract

### Postmark (unchanged default)

~~~bash
MAIL_DELIVERY_METHOD=postmark
POSTMARK_API_TOKEN=<runtime-secret>
POSTMARK_HOOK_ID=<runtime-secret>
POSTMARK_HOOK_SECRET=<runtime-secret>
~~~

### SMTP: STARTTLS submission, typically port 587

~~~bash
MAIL_DELIVERY_METHOD=smtp
SMTP_ADDRESS=mail.example.org
SMTP_PORT=587
SMTP_DOMAIN=example.org
SMTP_USERNAME=mailer@example.org
SMTP_PASSWORD=<runtime-secret>
SMTP_AUTHENTICATION=plain
~~~

For an authorized internal relay, omit the last three credentials/auth variables.
Do not use an unauthenticated public relay. This configuration requires
STARTTLS and valid server certificates; plain Mailpit on 1025 needs an
explicit TLS-enabled test configuration. Direct implicit TLS on port 465 is
not part of this first iteration.

The `From` address can vary per school. A confirmed school sender is not
automatically authorized by an SMTP relay. Validate relay authorization and
SPF/DKIM/DMARC alignment for default and custom school sender domains.

## Automated tests to run

~~~bash
bundle exec rspec spec/lib/mail_delivery_configuration_spec.rb \
  spec/services/email_bounces/record_service_spec.rb \
  spec/requests/users/postmark_webhook_bounce_reports_spec.rb \
  spec/system/bounced_emails_spec.rb \
  spec/mailers/school_mailer_spec.rb
~~~

Then run the existing sign-in, password-reset and enrollment specs and the
full suite as CI permits. Confirm suppression for pre-existing `BounceReport`
addresses after switching transports, including cross-school semantics.

## Operator acceptance: REQUIRED before asserting end-to-end DPG evidence

1. Build the Docker image with no Postmark token (and no secrets in layers).
2. Boot a production-like deployment using only SMTP transport; verify
   valid STARTTLS and invalid/missing values fail safely.
3. Deliver a real LMS login link, password reset, enrollment notice, coach
   feedback and deletion email through the selected SMTP relay.
4. Process at least one `deliver_later` using the existing Delayed Job worker.
5. Verify both the default and a confirmed school-specific From address; test
   actual inbox delivery and sender-domain authentication.
6. Verify existing suppression records still prevent sends and auth flows
   behave as before. Replay duplicate Postmark events.
7. Wire one open/self-hosted SMTP provider's authenticated permanent-bounce
   and complaint notifications into the recording service, demonstrate
   temporary failure exclusion, and record the results. This adapter is
   NOT part of the implementation yet and must not be represented as done.
8. Record the nominated commit, deployment recipe, test output, and provider
   dependencies in the DPGA evidence index.

## Rollout and rollback

- Do not switch an existing hosted deployment by default.
- First run a separate test environment with a test domain and limited users.
- Watch worker failures, SMTP rejections, bounce records, rate limits and
  suppressed email outcomes. A relay accepting a message does not prove final
  inbox delivery.
- Roll back a test or production deployment by restoring
  `MAIL_DELIVERY_METHOD=postmark` with valid runtime credentials, restarting
  workers and web processes, and reconciling any failed/queued messages before
  retrying to avoid duplicates.

## Out of scope / remaining DPGA risks

- No mail-server deployment or production external delivery performed here.
- No open SMTP provider-specific bounce-webhook adapter yet.
- No change to global suppression semantics, delivery audit or retention.
- No per-school SMTP credentials or custom transport abstraction.
- AWS/S3 independence, content safety, child protection, current legal
  compliance and other DPGA indicators remain separate workstreams.
- A successful SMTP smoke test is not a security review or DPG certification.

## References

- Rails 7.1 Action Mailer configuration:
  https://guides.rubyonrails.org/v7.1/configuring.html#config-action-mailer-smtp-settings
- DPG Standard: https://github.com/DPGAlliance/DPG-Standard
- Existing implementation: `config/environments/production.rb`,
  `app/mailers/school_mailer.rb`,
  `app/controllers/users/postmark_webhook_controller.rb`,
  `db/schema.rb`.
