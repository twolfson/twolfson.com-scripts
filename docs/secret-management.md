# Secret management
> This is a working thought/document
>
> But our experience with SOPS and various services has informed us of what's good, bad, and impractical
>
> So we'd like to update what we have here in `twolfson.com-scripts`

Over time and through experience, our opinion around secret management has changed

At its core, secret managment should be:

- Easy to use
- Secure to the server/network, anything more paranoid than this is overkill (e.g. per-user permissions)
  - We can have a rabbit hole discussion around file access vs shell access but usually our services need to read the secrets somehow, so it would have to be aware of how to decrypt encrypted-at-rest files, which we have yet to do
- Easy to reset upon leak

Attack vectors:
- Reading arbitrary filepath
- Arbitrary shell execution
