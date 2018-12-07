
# Why forking?

I maintained a fork of the official projet because:

- Run under alpine 3.8
- Added [UPX](https://github.com/upx/upx)
- Added `curl` to do the healthcheck when `docker service create`
- Added tiny
- Removed exposing 80 443 as it’s manage by Traefik
- **Caddyfile config use case**: I don’t use it as a proxy but only to host a pure static website. No auth or anything fancy.
- **A+** on [security header](https://securityheaders.com/) is active

**Screenshot**:

![screen shot 2018-12-06 at 7 48 19 pm](https://user-images.githubusercontent.com/6694151/49621138-e574a080-f991-11e8-8a8e-d9a2b2a4a974.jpg)

# Usage

Serve files in `$PWD`:
```
docker run -it --rm -p 2015:2015 -v $PWD:/srv productionwentdown/caddy
```

Overwrite `Caddyfile`:
```
docker run -it --rm -p 2015:2015 -v $PWD:/srv -v $PWD/Caddyfile:/etc/Caddyfile productionwentdown/caddy
```

Persist `.caddy` to avoid hitting Let's Encrypt's rate limit:
```
docker run -it --rm -p 2015:2015 -v $PWD:/srv -v $PWD/Caddyfile:/etc/Caddyfile -v $HOME/.caddy:/etc/.caddy productionwentdown/caddy
```
