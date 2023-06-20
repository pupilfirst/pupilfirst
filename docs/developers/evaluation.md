---
id: evaluation
title: Evaluating Pupilfirst LMS
sidebar_label: Evaluation
---

If you're looking to quickly evaluate whether Pupilfirst LMS is suitable for
your needs, you can run the LMS in a single step using
[Docker Compose](https://docs.docker.com/compose/).

After cloning [our GitHub repository](https://github.com/pupilfirst/pupilfirst), and with Docker installed on your system, run...

```bash
docker compose up
```

...from the root of the cloned repo.

Once Docker Compose shows the message `Listening on http://0.0.0.0:3000`, visit
[http://localhost:3000](http://localhost:3000) in your browser.

What you'll see is the LMS running in the `development` environment with its
database _seeded_ with demonstration data.

- You can sign into the school as an admin by using the _Developer_ sign-in
  option and supplying the email address `admin@example.com`.
- To view the app as a student, you can sign in using the email address
  `student1@example.com`.
