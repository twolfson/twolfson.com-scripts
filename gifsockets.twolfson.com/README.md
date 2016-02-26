# gifsockets.twolfson.com
Scripts for <http://gifsockets.twolfson.com/>

The folder structure and scripts are similar to its parent folder

# Idea 1
- data stays the same-ish but we move to templates for things NGINX files and supervisord.conf
    - Honestly can't know if plausible until we get provisioning fully set up...
    - Also, consider relocating
- Create a `Vagrantfile` in this directory
    - Maybe create a similar setup for `twolfson.com` which has a symlinked `Vagrantfile -> twolfson.com/Vagrantfile`

# Idea 2
- Put all content at the top level with multiple machines
    - Dislike this idea because it scales poorly
