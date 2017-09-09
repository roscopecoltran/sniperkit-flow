# Node-RED on Alpine Linux 

## With Docker/Moby

### Build:
```bash
docker build -t node-red-ui -f node-red-ui.alpine.dockerfile .
```

### Re-Build (with no-cache):
```bash
docker build -t node-red-ui --no-cache -f node-red-ui.alpine.dockerfile .
```

### Run:
```bash
docker run --rm -p 1880:1880 node-red-ui
```

## With Docker-Compose

### run non-detached
docker-compose up

### run detached
docker-compose up

### stop all containers
docker-compose stop --all