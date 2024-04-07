# 不安全端口

1. 启动剧本

  ```bash
  ansible-playbook insecure-port.yml
  ```

Then get a note of the IP address of the Kubernetes cluster from the output of the ansible playbook or with 

```
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' insecureport-control-plane
```

Connect to your client container

```
docker exec -it client /bin/bash
```

At this point you should be able to reach the Insecure API port on the vulnerable cluster.  Check with

```
nmap -sT -v -n -p8080 [CLUSTERIP]
```