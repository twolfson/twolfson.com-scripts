# gifsockets.twolfson.com
Scripts for <http://gifsockets.twolfson.com/>

The folder structure and scripts are similar to its parent folder

# Initial setup
- [x] Set up multi-machine Vagrant
- [ ] data stays the same-ish but we move to templates for things NGINX files and supervisord.conf
    - Rename some files like `twolfson.com` to `reverse-proxy.conf.erb`
- [ ] Need to figure out how to handle scripts...
    - I'm thinking make them all the same and make things like `twolfson.com` a parameter or use callbacks? (e.g. call `restart_command`)

# After setup
- [ ] Document new files and Vagrant setup
- [ ] Break down tests into common, twolfson.com (in `twolfson.com/test`), and `gifsockets.twolfson.com/test`
    - Maybe define a `test.sh` for each and have the main `test.sh` call them all
    - Be sure to assert against template output (e.g. `assert 'twolfson.com.conf'.contents == 'twolfson.com.conf'.contents`)

