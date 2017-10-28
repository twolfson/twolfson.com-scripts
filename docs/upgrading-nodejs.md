# Upgrading Node.js
We don't yet have an integration with unattended releases. As a result, we need to upgrade Node.js manually whenever a new release comes out. Here's some helpful commands to make the upgrade process trivial:

```bash
# Find our current Node.js version
git grep nodejs
# src/cookbooks/twolfson.com/recipes/default.rb:7:# DEV: Equivalent to `sudo apt-get install -y "nodejs=6.11.4-1nodesource1"`
#   Our version: 6.11.4

# Find latest Node.js version
# DEV: This relies on https://www.npmjs.com/package/n
n ls
# ...
# 6.11.4
# 6.11.5
# 7.0.0
# ...
#   Latest version: 6.11.5

# Replace all non-symlink references for Node.js version
sed --in-place "s/{{our_version}}/{{latest_version}}/g" -- $(find src test -type f)
#   Example:
#   sed --in-place "s/6\.11\.4/6\.11\.5/g" -- $(find src test -type f)

# Sanity check replacement
git grep '{{version}}'
#   Example:
#   git grep '6\.11\.4'

# Add changes
git add -p

# Commit changes
git commit -m "Upgraded to Node.js {{version}} to fix Travis CI"
#   Example:
#   git commit -m "Upgraded to Node.js 6.11.5 to fix Travis CI"

# Push changes and wait for Travis CI to approve
git push origin {{branch}}
```
