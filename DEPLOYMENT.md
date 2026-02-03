# Redirector Deployment

This service implements per-host redirects using flat files under `/srv/www`.

## URL format

Redirect endpoint:

    [base_url]/post/<id>/rd

Example:

    https://www.downes.ca/post/12345/rd

The service returns:

- `302 Location: <target-url>` if a valid redirect is found
- `404` if the request does not match the route or the redirect file is missing/invalid
- `403` if path resolution escapes the allowed directory (safety check)

## How redirects are stored

Redirects are stored as files under:

    /srv/www/<host>/_rd/<p>/<l>

Where:

- `<host>` is derived from the request `Host:` header (port stripped, sanitized)
- `<id>` is the numeric post id from the URL
- `<p> = int(<id> / 100)`
- `<l> = <id> % 100`

Example for host `www.downes.ca` and id `12345`:

- `p = 123`
- `l = 45`

File path:

    /srv/www/www.downes.ca/_rd/123/45

## File contents

Each redirect file contains the target URL on the first line, e.g.:

    https://example.com/some/page

Rules:

- Leading/trailing whitespace is trimmed
- Only `http://` and `https://` targets are accepted
- Anything else results in `404`

## Server layout

Expected paths on the server:

- Application repo:
  - `/srv/apps/redirector`
- Redirect storage base:
  - `/srv/www`
- Per-host redirect trees:
  - `/srv/www/<host>/_rd/...`

This repository does not store redirect data files.

## Updating the service

From the server:

    cd /srv/apps/redirector
    git pull origin main

Then reload/restart the service (depends on how it is run on this server).
