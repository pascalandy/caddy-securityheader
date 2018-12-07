**Caddyfile config use case**: I don’t use it as a proxy but only to host a static website. No auth or anything fancy here.


# Why forking?

I maintained a fork of the official projet because:

- Cache is active
- Run under alpine 3.8 (not scratch)
- Added [UPX](https://github.com/upx/upx)
- Added `curl` to do the healthcheck when `docker service create`. You must use healthcheck for serious orchestration.
- Added [tiny](https://github.com/krallin/tini), init for containers 
- Removed exposing 80 443 as it’s manage by Traefik (proxy). See my super-duper [docker-stack](https://github.com/pascalandy/docker-stack-this) for a better context. 


# Security Header screenshot

Get an **A+** on [security header](https://securityheaders.com/) out of the box. 

Before I was using CloudFlare worker (5$ per month) to get the same result. I asked myself, how does the ‘real server’ are configured to manage the scurity-header? This is how.

![screen shot 2018-12-06 at 7 48 19 pm](https://user-images.githubusercontent.com/6694151/49621138-e574a080-f991-11e8-8a8e-d9a2b2a4a974.jpg)


# Smaller than the official image

More features, much lighter. In the screenshot, you see the uncompressed sized on my local machine.

![screen shot 2018-12-07 at 12 11 25 am](https://user-images.githubusercontent.com/6694151/49628880-b3286a80-f9b4-11e8-8004-216c737d80d1.jpg)


# Usage

Launch those three bash scripts from your terminal:

```
./runup.sh
./runup-caddyfile.sh (mount the Caddyfile)
./rundown.sh
```