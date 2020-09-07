# Secret management
> This is a working thought/document
>
> But our experience with SOPS and various services has informed us of what's good, bad, and impractical
>
> So we'd like to update what we have here in `twolfson.com-scripts`

Over time and through experience, our opinion around secret management has changed

At its core, secret managment should be:

- Easy to use
- "Secure enough", i.e. secure to the server/network
- Easy to reset upon leak

We've used a bunch of security options in the past:

- Using a private repo with `.env` file
  - Pros: Really easy to get new devs up and running
  - Cons: If repo becomes public for any reason, then secrets are all leaked
- Using SOPS with PGP
  - Pros: Decent security in principle, secrets can be stored in public repo
  - Cons: Tedious to pass around valid keys, doesn't truly guarantee more security
- Using Heroku/Lambda/Vercel environment variables, maintained via UI/CLI
  - Pros: All devs get access with deploy rights
  - Cons: Can get out of sync with service but can be avoided by convention (e.g. never reuse keys for different purposes)

In our opinion, there are 2 major attack vectors to consider:

- Arbitrary shell execution
  - If someone gets access to this, then it's game over
  - They can read/write variableas the program so best not to think about
- Reading an arbitrary filepath
  - This can be protected against, kind of
  - Fundamentally we'll need some credentials somewhere to perform decryption and those will be stored in a file
  - Otherwise, the server won't know what to do upon restart
  - Unless we use an intranet server to manage our secrets which is overkill/tedious to manage for individuals and small companies
    - Not to mention making each service have asynchronous boot with single point of failure around secret management service

Based on the logic above, we use the following downgrade chain:

- If there's an existing solution use that
  - Company has intranet secret management
  - Provider has UI to manage secrets
- Otherwise, use a local file on the server (e.g. `.env`, `secrets.json`)
  - Avoid committing file in repo if possible as who knows when the repo might go public
  - However, this can also be a tolerable risk (e.g. leaking source code might expose other known vulnerabilities in dependencies)
  - Use symlinking to make maintenance as easy as possible (same filepath always)
  - Use as little indentation as possible to avoid unnecessary complexity
  - Keep keys sorted if possible for easier maintenance
