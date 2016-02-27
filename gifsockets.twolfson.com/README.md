# gifsockets.twolfson.com
Scripts for <http://gifsockets.twolfson.com/>

The folder structure and scripts are similar to its parent folder

# Initial setup
- [ ] data stays the same-ish but we move to templates for things NGINX files and supervisord.conf
    - Rename some files like `twolfson.com` to `reverse-proxy.conf.erb`
- [ ] Create a `Vagrantfile` in this directory
    - Maybe create a similar setup for `twolfson.com` which has a symlinked `Vagrantfile -> twolfson.com/Vagrantfile`
- [ ] Need to figure out how to handle scripts...
    - I'm thinking make them all the same and make things like `twolfson.com` a parameter or use callbacks? (e.g. call `restart_command`)

# After setup
- [ ] Document new files
- [ ] Break down tests into common, twolfson.com (in `twolfson.com/test`), and `gifsockets.twolfson.com/test`
    - Maybe define a `test.sh` for each and have the main `test.sh` call them all
    - Be sure to assert against template output (e.g. `assert 'twolfson.com.conf'.contents == 'twolfson.com.conf'.contents`)


Another thought seems to be:
- Use `VAGRANT_VAGRANTFILE` with something like a `virtualenv` to switch between them

Dead end with separate folders, looks like "Another thought" will be our best option for something functional with sane DRY-ness

- Make files like `twolfson.com.Vagrantfile`
- Make files like `gifsockets.twolfson.com.Vagrantfile`
- Symlink default `Vagrantfile` to `twolfson.com.Vagrantfile`
- Write a script like `env/bin/activate` which appends to `PS1` and defines a `deactivate`
- Then, store lots of things in similar/the same folders and we should be "good enough" until 5 node types or so (which we haven't reached yet)
