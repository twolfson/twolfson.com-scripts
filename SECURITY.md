# Security
We try to keep our services as secure as possible via the following means:

- Restricting shell access for SSH users
- Preventing password only authentication for SSH
- Restricting permissions on sensitive files (e.g. SSL certificates, NGINX configurations)

## Patched major CVE's
We have gone out of our way to patch the following CVE's

### Current
We have not needed to patch anything yet for a new server.

### Historical
These applied to previous servers and major versions:

- [x] Shellshock - Patched by upgrading bash (default is fine on Ubuntu 14.04)
    - https://krebsonsecurity.com/2014/09/shellshock-bug-spells-trouble-for-web-security/
- [x] Heartbleed - Patched by upgrading NGINX (default is fine on Ubuntu 14.04)
    - https://heartbleed.com/
- [x] POODLE - Patched by restricting SSL methods used by NGINX
    - https://access.redhat.com/articles/1232123
    - https://cipherli.st/
- [x] Logjam - Patched by using new Diffie-Hellman group
    - https://weakdh.org/sysadmin.html
