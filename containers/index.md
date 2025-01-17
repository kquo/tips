# Containers
Container tips.

## Install Docker on Ubuntu
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

## Install Docker Compose on Ubuntu
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


## Build an Almost Empty Image
To build an almost empty container image, build using `FROM scratch`, for example:

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

## Command Docker Commands
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
