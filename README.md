# icecast-kh-docker

Minimal Alpine-based Docker image for [Icecast](https://icecast.org/), built from source.

## Requirements

- Docker
- Docker Compose

## Usage

1. Edit `config/icecast.xml` to suit your setup.
2. Build and start:
   ```sh
   docker compose up -d
   ```

Icecast will be available at `http://localhost:8000`.

Logs are written to `./logs/`. Config is mounted read-only from `./config/icecast.xml`.

## Configuration

Point your log paths in `icecast.xml` to `/var/log/icecast/`:

```xml
<logging>
    <accesslog>/var/log/icecast/access.log</accesslog>
    <errorlog>/var/log/icecast/error.log</errorlog>
</logging>
```

## Changing versions

Icecast and libigloo versions are set as build arguments at the top of the `Dockerfile`:

```dockerfile
ARG ICECAST_VERSION=2.5.0
ARG IGLOO_VERSION=0.9.5
```

Or override at build time:

```sh
docker build --build-arg ICECAST_VERSION=2.5.1 --build-arg IGLOO_VERSION=0.9.5 .
```
