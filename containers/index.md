# Containers
Container tips.

## Install Docker

### On RedHat/Alma Linux

```bash
sudo dnf update -y
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

Logout and log back in for group changes to take effect.

### On Ubuntu
Based on <https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04>

- To install Docker on Ubuntu 20.04: 

```bash
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce
sudo systemctl status docker
sudo docker run hello-world
```

- After installation, trying `docker ps` will show an error, so to run Docker **without** having to use sudo:

```bash
sudo usermod -aG docker ${USER}
# Log out then back in
docker run hello-world
```

- To add additional users: `sudo usermod -aG docker USERNAME`

**Also install Docker Compose**

Docker Compose allows one to define and run multi-container applications with Docker. A multi-container application can be defined in a single file (usually called `docker-compose.yaml`), then spun up with a single command (usually `docker-compose up`) and that gets everything running.

This is based on <https://linuxize.com/post/how-to-install-and-use-docker-compose-on-ubuntu-20-04/>.
- Ensure Docker is already installed
- Check latest release at <https://github.com/docker/compose/releases>

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

## Public Docker Registry Logon
To login using your own Docker Hub username (cannot use email from CLI) simply do: `docker login`


## Docker Images

### Very Small Image
To build an almost empty container Docker image, build using `FROM scratch`, for example:

```bash
$ vi hello.sh
#!/bin/bashd
echo Hello
$ chmod 755 hello.sh
$ vi Dockerfile
FROM scratch
ADD hello.sh /
CMD ["/hello.sh"]
$ docker build .
```

### Docker Multi-Stage Builds for Standalone Go Binaries

Docker multi-stage builds offer several key advantages for **standalone Go binaries**, combining build-time flexibility with minimal final images:

**Core Benefits**:
1. **Tiny Production Images** (~10-20MB)
   - Final image contains *only* the binary (no compiler, SDK, or build tools)
   - Example: `FROM scratch` images for truly minimal deployments

2. **Build-Time Isolation**
   - Complex build dependencies (like CGO, code generators) stay in build stage
   - No risk of build tools ending up in production

3. **Security Hardening**
   - No unnecessary packages = smaller attack surface
   - Can use `distroless` or `scratch` as final base

4. **Single Dockerfile Workflow**
   ```bash
   # Stage 1: Build
   FROM golang:1.21 as builder
   WORKDIR /app
   COPY . .
   RUN CGO_ENABLED=0 go build -o /bin/app ./cmd/main.go

   # Stage 2: Runtime  
   FROM scratch
   COPY --from=builder /bin/app /app
   ENTRYPOINT ["/app"]
   ```
5. **Build Cache Optimization**
   - Dependency downloads cached separately from code changes
   - Faster rebuilds when only source files change

**Go-Specific Advantages**:
   - **Static Binaries Work Perfectly**  
     `CGO_ENABLED=0` builds run natively in `scratch` images
   - **No Runtime Dependencies**  
     Go binaries include everything needed (unlike Python/Java)
   - **Cross-Compilation Support**  
     Build for Linux AMD64 from macOS/Windows in CI

**Real-World Impact**:
   | Metric       | Single-Stage | Multi-Stage |
   |--------------|--------------|-------------|
   | Image Size   | ~800MB       | ~10MB       |
   | CVEs         | 100+         | 0           |
   | Build Time   | 2min         | 1min (cached)|

**When Not To Use**:
   - If you need shell access for debugging in production, swap `scratch` for `alpine` (still only ~5MB).

## Command Commands
```bash
docker search jenkins                                     # Sample search
docker run -it centos                                     # Run image with interactive terminal shell
docker stop ID                                            # Stop running container
docker ps [-a]                                            # Lists running containers [non running ones]
docker rm ID                                              # Delete container
docker image ls                                           # List all images
docker rmi ID                                             # Delete image
docker logs -f ID                                         # Show standard output, tail option
docker tag centos centos:7.1.1503                         # Add a tag to existing image
docker cp foo.txt mycontainer:/foo.txt                    # Copy file to container
docker run -it -v ./scimsession:/scimsession centos bash  # Mount local file on container
docker container prune                                    # Remove all old containers
docker system prune                                       # Remove all old settings
docker container exec -it CONTA_NAME /bin/bash            # Attach to running container
docker top hungry_brahmagupta                             # Show container process list
docker exec -it c44b36e02322 /bin/bash                    # Open bash on/connect to running container

# Instantiate image, put in background, and expose ports to local random ports
docker run -d -P training/webapp python app.py

# Instantiate image, put in backgrnd, and expose port 5000 to 80 local
docker run -d -p 80:5000 training/webapp python app.py

# Run redis locally
docker run -d -p 6379:6379 redis

# Instantiate simple python HTTP server, expose port 8000 on 80 local
# Browsing http://192.168.99.100/ will show centos container file system
docker run -it -p 80:8000 centos:7.1.1503 python -m SimpleHTTPServer

# Instantiate image, and join to specific network
docker run -d --net=my-bridge-network --name db training/postgres

# Instantiate image, and attach to volume, with read-only option
docker run -d -P --name webapp[:ro] -v /webapp training/webapp python app.py

# Instantiate image, and attach to specific host volume, with read-only option
docker run -d -P --name /src/webapp:/opt/webapp[:ro] -v /webapp training/webapp python app.py

# Create a volume named dbdata
docker create -v /dbdata --name dbdata training/postgres /bin/true

# Instantiate image, and attach all volumes from dbdata Data Volume Container
docker run -d --volumes-from dbdata --name db1 training/postgres
```

## Docker Networking
To create an external network with a specific IP CIDR range:

```bash
docker network create --gateway 10.10.4.1 --subnet 10.10.4.0/24 NETNAME
```

## Docker Volumes
Docker volumes are usually kept under `/var/lib/docker/volumes/` and by default only accessible by `root`.

## Docker for Mac
HyperKit VM Shell

```bash
screen ~/Library/Containers/com.docker.docker/Data/vms/0/tty
linuxkit-025000000001:~# 
```

## Kubernetes
**Kubernetes** is a production-grade, open-source platform that orchestrates the placement (scheduling) and execution of application *containers* within and across computer clusters. Key elements:

- **Deployment**: A Deployment is responsible for creating and updating instances of your application

- **Node**: A node is a worker machine in Kubernetes and may be a VM or physical machine, depending on the cluster. Multiple Pods can run on one Node.
  Pod

- **Pod**: A Pod is a group of one or more application containers (such as Docker or rkt) and includes shared storage (volumes), IP address and information about how to run them.

- **Service**: A Kubernetes Service is an abstraction layer which defines a logical set of Pods and enables external traffic exposure, load balancing and service discovery for those Pods.

- **Helm Chart**: A Helm chart encapsulates a group of YAML definitions composing a specific application/package. It provides a mechanism for configuration at deploy-time and allows you to define metadata and documentation that might be useful when sharing the package. Helm can be useful in different scenarios:
  - Find and use popular software packaged as Kubernetes charts
  - Share your own applications as Kubernetes charts
  - Create reproducible builds of your Kubernetes applications
  - Intelligently manage your Kubernetes object definitions
  - Manage releases of Helm packages

- **Criticism**: There are many who argue that for many shops Kubernetes is unncessarily complex and probably should be avoided. In many cases it is easier to run Docker alone, maybe using Compose or Swarm.

## Docker Swarm
Docker Swarm is native clustering for Docker. It turns a pool of Docker hosts into a single, virtual host. Swarm serves the standard Docker API, so any tool which already communicates with a Docker daemon can use Swarm to transparently scale to multiple hosts: Dokku, Compose, Krane, Deis, DockerUI, Shipyard, Drone, Jenkins ... and, of course, the Docker client itself.

## kubeadm
Creating a single control-plane cluster with kubeadm.

See <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/>

**kubeadm** helps you bootstrap a minimum viable Kubernetes cluster that conforms to best practices. With kubeadm, your cluster should pass Kubernetes Conformance tests. Kubeadm also supports other cluster lifecycle functions, such as upgrades, downgrade, and managing bootstrap tokens.

Because you can install kubeadm on various types of machine (e.g. laptop, server, Raspberry Pi, etc.), it’s well suited for integration with provisioning systems such as Terraform or Ansible.

## kubectl Common Commands
`kubectl` is Kubernetes's Swiss Army knife. Command commands are:

```bash
kns kube-system
kubectl get all 
kubectl describe pod calico-kube-controllers-5d94b577bb-jp5hz
kubectl logs calico-kube-controllers-5ff94b558-vhjtm --namespace kube-system

BASICS
kubectl config set-context kube-system                         # Set namespace to kube-system 
kns kube-system                                                # Set namespace to kube-system with kns 
kubectl describe pod calico-kube-controllers-5ff94b558-vhjtm   # Describe pod
kubectl logs calico-kube-controllers-5ff94b558-vhjtm           # Show logs
kubectl -n kube-system logs calico-node-t9mfs                  # Show logs on specific namespace pod
kubectl apply -f CONFIG.yaml                                   # Deploy a resource
kubectl delete -f CONFIG.yaml                                  # Delete that resource
kubectl delete rs coredns-6955765f44                           # Delete specific resource: Replica Set
kubectl delete pods,services -l name=myLabel                   # Delete pods, services with specific label

BACKUP
kubectl get globalconfig --all-namespaces --export -o yaml > global-configs.yaml
kubectl get ippool --all-namespaces --export -o yaml > ip-pools.yaml
kubectl get systemnetworkpolicy.alpha --all-namespaces --export -o yaml > system-network-policies.yaml
```

## Docker Compose
Two very rough examples of using **docker compose**.

1. **Testing a Go Binary**:
  - This example builds an multi-state image with the `azm` utility as a sole binary:
  - The `Dockerfile`:

     ```bash
     # # On Debian GNU/Linux 12 (bookworm) - image size ~= 928MB
     # FROM golang:latest
     # or
     # On Alpine Linux v3.18  - image size ~= 335MB
     FROM golang:alpine
     #
     WORKDIR /app
     COPY . .
     # Note that GOPATH=/go
     RUN go build -ldflags "-s -w" -o /go/bin/azm
     CMD ["azm"]

     # EXPLORE multistage builds - image size ~= really small is the promise!
     # # STEP 1: Build your binary
     # FROM golang:alpine AS builder
     # RUN apk update
     # RUN apk add --no-cache git ca-certificates tzdata && update-ca-certificates
     # COPY . .
     # #RUN go get -d -v ./...
     # #RUN go build -o /bin/my-service
     # RUN go build -ldflags "-s -w" -o /bin/azm
     # 
     # # STEP 2: Use Scratch to build your smallest image
     # FROM scratch
     # COPY --from=builder /etc/ssl/certs/* /etc/ssl/certs/
     # COPY --from=builder /bin/ /bin/
     # CMD ["/bin/azm"]
     ```

  - The `docker-compose.yaml` files:

     ```bash
     version: '3'
     services:
       azm:
         build:
           context: .  # Path to your GoLang application code
           dockerfile: Dockerfile
         image: azm
         command: sh -c '
           echo "===========" &&
           cat /etc/os-release &&
           echo "===========" &&
           azm -id &&
           echo "===========" &&
           azm -s'
         container_name: azm
         volumes:
           - ./:/app
         environment:
           - MAZ_CLIENT_ID=${MAZ_CLIENT_ID}
           - MAZ_CLIENT_SECRET=${MAZ_CLIENT_SECRET}
           - MAZ_TENANT_ID=${MAZ_TENANT_ID}
         working_dir: /app

     # BUILD & RUN: docker compose up --build
     # JUST RUN   : docker compose up
     # INSPECT    : docker compose run --build azm bash
     ```

2. **Testing a Python script that gets Azure tokens**:
  - Working Docker and Docker Compose environment. Note that below examples are using version 2 of Docker Compose.
  - References:
    - Installing Docker: <https://docs.docker.com/engine/install/rhel/>
    - Docker Compose: <https://docs.docker.com/compose/compose-file/compose-file-v3/>
  - Docker Socket Issues:
    - If you encounter any `permissions denied` issues with the docker daemon, try these commands:
       ```bash
       sudo usermod -aG docker your_username     # Ubuntu
       sudo usermod -aG podman your_username     # RHEL
       sudo systemctl restart docker
       docker run hello-world                    # To confirm it is fixed

       # Alternatively, try 
        
       sudo chown your_username:docker /var/run/docker.sock
       sudo chmod 660 /var/run/docker.sock
       ```
  - Make sure you define/export the 3 required environment variables: 

     ```bash
     export MAZ_TENANT_ID="tenant-id-uuid-string"
     export MAZ_CLIENT_ID="your-client-ID-uuid-string"
     export MAZ_CLIENT_SECRET="client-secret-string"
     ```

  - Then you can build and run for the first time, or run subsequent times.
      - `docker compose up --build`: To build and run for the first time.
      - `docker compose up`: To run subsequent times.
    - You can edit `aztoken.py` file to play with different behavior, like using a different scope and so on.
  - The `docker-compose.yaml` files:

     ```bash
     # docker-compose.yaml

     version: '3'
     services:
       python_app:
         image: python:3.10-slim  # On Debian GNU/Linux 12 (bookworm)
         command: bash -c '
           cat /etc/os-release &&
           pip install msal &&
           python /app/aztoken.py'
         volumes:
           - ./:/app
         environment:
           - MAZ_CLIENT_ID=${MAZ_CLIENT_ID}
           - MAZ_CLIENT_SECRET=${MAZ_CLIENT_SECRET}
           - MAZ_TENANT_ID=${MAZ_TENANT_ID}
         working_dir: /app

     # BUILD & RUN: docker compose up --build
     # JUST RUN   : docker compose up
     # INSPECT    : docker compose run --build python_app bash
     ```

  - The `aztoken.py` script:

     ```python
     # aztoken.py

     import sys
     import time
     import os
     import json
     from datetime import datetime, timedelta
     import signal
     import msal

     BLUE = '\x1b[1;34m'
     GREEN = '\x1b[32m'
     RED = '\x1b[31m'
     RESET = '\x1b[0m'

     cache = msal.TokenCache()   # Initialize a global token cache

     # Quick exit on CTRL-C
     def exit_gracefully(signal, frame):
         sys.exit(0)
     signal.signal(signal.SIGTERM, exit_gracefully)
     signal.signal(signal.SIGINT, exit_gracefully)

     def print_flush(message):
         print(message)
         sys.stdout.flush()

     def expiry_date(expires_in_seconds):
         current_time = datetime.now()
         if expires_in_seconds == None:
             expires_in_seconds = 0
         expiry_date_temp = current_time + timedelta(seconds=expires_in_seconds)
         return expiry_date_temp.strftime('%Y-%m-%d %H:%M:%S')

     def get_token_by_credentials(scopes, client_id, client_secret, authority_url):
         # Define the client application using MSAL
         cca = msal.ConfidentialClientApplication(
             client_id,
             authority=authority_url,
             client_credential=client_secret,
             token_cache=cache  # Use the global cache
         )

         # Acquire a token using client credentials
         token_request = {
             'scopes': scopes
         }

         try:
             result = cca.acquire_token_for_client(scopes=scopes)
             return result
         except Exception as error:
             raise Exception(f"Error acquiring token: {str(error)}")

     def main():
         # scopes = ['https://graph.microsoft.com/.default']
         # scopes = ['https://management.azure.com/.default']
         scopes = ['https://ossrdbms-aad.database.windows.net/.default']
         client_id = os.environ.get('MAZ_CLIENT_ID')
         client_secret = os.environ.get('MAZ_CLIENT_SECRET')
         tenant_id = os.environ.get('MAZ_TENANT_ID')
         authority_url = f'https://login.microsoftonline.com/{tenant_id}'

         while True:
             token = get_token_by_credentials(scopes, client_id, client_secret, authority_url)
             if 'access_token' not in token:
                 print_flush(f"{RED}Failed to obtain token: {token}{RESET}")
             #print(json.dumps(token, indent=2))  # OPTION: Print entire token structure

             access_token = token.get('access_token')
             expires_in_secs = token.get('expires_in')
             expires_in = expiry_date(expires_in_secs)

             print_flush(f"\n{BLUE}TOKEN DETAILS{RESET}:")
             print_flush(f"{BLUE}  client_id{RESET} : {GREEN}{client_id}{RESET}")
             print_flush(f"{BLUE}  Authority{RESET} : {GREEN}{authority_url}{RESET}")
             print_flush(f"{BLUE}  Scopes{RESET}    : {GREEN}{scopes}{RESET}")
             print_flush(f"{BLUE}  Token{RESET}     : {GREEN}{access_token}{RESET}")
             print_flush(f"{BLUE}  Expires On{RESET}: {GREEN}{expires_in}{RESET} ({expires_in_secs} seconds)")

             # Wait for 5 seconds (5,000 milliseconds) before making the next call
             time.sleep(5)

     if __name__ == "__main__":
         main()
     ```
