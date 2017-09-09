# Noflo-Server-Graph on Alpine Linux 

## With Docker/Moby

### Build:
```bash
docker build -t noflo-server-graph -f noflo-server-graph.alpine.dockerfile .
```

### Re-Build (with no-cache):
```bash
docker build -t noflo-server-graph --no-cache -f noflo-server-graph.alpine.dockerfile .
```

### Run:
```bash
docker run --rm -p 3569:3569 noflo-server-graph
```

## With Docker-Compose

### run non-detached
docker-compose up

### run detached
docker-compose up

### stop all containers
docker-compose stop --all