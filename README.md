# transmission-port-forward-gluetun-server

A shell script and Docker container for automatically setting transmissions's listening port from Gluetun's control server.

## Config

### Environment Variables

| Variable              | Example                    | Default                 | Description                                        |
| --------------------- | -------------------------- | ----------------------- | -------------------------------------------------- |
| TRANSMISSION_USERNAME | `username`                 | `transmission`          | transmission username                              |
| TRANSMISSION_PASSWORD | `password`                 | `transmission`          | transmission password                              |
| TRANSMISSION_ADDR     | `http://192.168.1.69:9091` | `http://localhost:9091` | HTTP URL for the transmission web UI, with port    |
| GTN_ADDR              | `http://192.168.1.69:8000` | `http://localhost:8000` | HTTP URL for the gluetun control server, with port |

## Example

### Docker-Compose

The following is an example docker-compose:

```yaml
  transmission-port-forward-gluetun-server:
    image: ispiropoulos/transmission-port-forward-gluetun-server
    container_name: transmission-port-forward-gluetun-server
    restart: unless-stopped
    environment:
      - TRANSMISSION_USERNAME=username
      - TRANSMISSION_PASSWORD=password
      - TRANSMISSION_ADDR=http://192.168.1.69:9091
      - GTN_ADDR=http://192.168.1.69:8000
```

## Development

### Build Image

`docker build . -t transmission-port-forward-gluetun-server`

### Run Container

`docker run --rm -it -e TRANSMISSION_USERNAME=username -e TRANSMISSION_PASSWORD=password -e TRANSMISSION_ADDR=http://192.168.1.69:9091 -e GTN_ADDR=http://192.168.1.69:9091 transmission-port-forward-gluetun-server:latest`

