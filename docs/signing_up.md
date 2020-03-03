# Signing Up

New students can enter a course in one of two ways:

1. A school admin [adds them via the students list](/students?id=adding-new-students).
2. [Public sign up is enabled](/courses?id=creating-courses) for a course.

## Signing Up For A Course

When the public signup option is enabled on a course, the course's public page gains an _Apply_ button.

![Course with public signup enabled](https://res.cloudinary.com/sv-co/image/upload/v1583227669/pupilfirst_documentation/signing_up/course_with_public_signup_dopsox.png)

Students can read about the course before enrolling to it by supplying their name and email address. Their email address
will be confirmed before they're added to the course, and they'll
[begin the course in the first level](/curriculum_editor?id=what-are-levels).

## Tagging Public Signups

If you're sharing the link to a course's page, you may want to include a `tag` parameter in the URL to track sign-ups
from that URL. To tag a new sign-up, simply include the name of an existing student tag in the URL like so:

```
https://my.school.domain/courses/ID?tag=existing-tag
```

1. This only works for _existing_ tags - this prevents misuse of the feature.
2. If your tag name contains spaces, make sure that [it's URL-encoded](http://www.utilities-online.info/urlencode/).

Students who sign up to a course after visiting this link will have the tag assigned to them.
