# TODO: Formalize this bit into docs
DEV: We are avoiding the Serverspec variation of documentation because:
    - Spaces and subjects felt too magical; it's at the cost of developers understanding what's going on
    - By not using subjects, we catch edge cases like IPv6 support

# TODO: Delete this file after completing everything
- [x] Verify `node@v0.10.41` is installed
- [x] Verify `bash@latest` is installed
- [x] Verify shellshock (bash), heartbleed (NGINX), poodle are resolved
- [x] Verify only open ports are 22, 80, and 443
- [ ] Verify only user with good default shell is ubuntu
    - [ ] It's possible to `sudo -u root --shell $SHELL`, right?
- [ ] Verify /etc/sshd configuration (e.g. only RSA handshake, no passwords)
- [x] Verify permissions on SSL certs (e.g. /etc/ssl/private)
- [x] Verify permissions on NGINX configs (e.g. /etc/nginx/conf.d)
- [ ] Secure OpenSSH server as well -- see cipherli.st
- [ ] TODO: Relocate SSL setup into `nginx.conf`
- [x] TODO: Look into HTTPS for www.
- [x] TODO: Remove `/etc/nginx/sites-{available,enabled}` or verify they are owned by root:root and only writable by owner and not executable by owner/group/other
- x] TODO: Support IPv6 HTTPS

- [ ] Next release, add drive setup
- [ ] Verify permissions on twolfson drive

- [ ] TODO: Look into why HTTPS for www. not redirecting in production

- [ ] In twolfson.com repo, prob add node security project check to test suite
- [ ] In twolfson.com repo, add GZIP checks
- [ ] In twolfson.com repo, /health with NODE_ENV=production check
