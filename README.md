# Kubernetes 本地安全测试实验环境

本项目可以利用 [Docker](https://www.docker.com) 和 [kind](https://kind.sigs.k8s.io/) 来在本地创建一个可以用于测试 Kubernetes 漏洞和安全工具的实验环境，而无需远程资源或启动虚拟机。

为了更加灵活的设置各种易受攻击的集群，我们使用了 [Ansible](https://www.ansible.com/) playbooks

如果你想了解工作原理以及如何开始，请查看 [rawkode live](https://www.youtube.com/watch?reload=9&v=Srd1qqxDReA&t=6s) 节目。

## 先决条件

在开始之前，你需要安装：

- Docker
- Ansible
  - 含需要安装 docker python 模块（例如 `pip install docker` 或 `pip3 install docker`）
- Kind 0.11.0 - 安装指南在[这里](https://kind.sigs.k8s.io/docs/user/quick-start/)
  - 注意：由于 Kind v0.11.0+ 的重大变更，目前只支持 Kind v0.11.0
  - 您可以使用 kind --version 检查您的版本

若安装先决条件时遇到问题，请查看[安装指南](https://www.youtube.com/watch?v=y9PbNDdtHGo)，它会引导你安装所有的依赖项。

如果您使用的是 Ubuntu 18.04，可以使用 `install_ansible_ubuntu.sh` 文件来进行 ansible 设置。如果您使用的是 Ubuntu 20.04，则可以直接通过 apt 获取 ansible。

## 开始

1. 从下面的列表中启动您想使用的易受攻击的集群。在 playbook 的末尾，您将获得集群的 IP 地址。
2. 启动客户机容器，并执行进入 shell
3. 对于 SSH 集群（以 ssh-to-* 开头的playbooks）使用 `ssh -p 32001 sshuser@[Kubernetes Cluster IP]` 和密码 `sshuser` SSH 进入集群上的一个 pod
4. 开始攻击 :)

下面是更详细的解释。

## 客户机

有一个带有 Kubernetes 安全测试工具的客户机，可以通过 [client-machine.yml](./client-machine.yml) 剧本启动。最好在运行场景时使用这个客户机进行所有的 CLI 任务，这样您就不会意外地从宿主机获取凭据，但记得在客户机之前启动 kind 集群，否则可能无法使用 Docker 网络进行连接。

- `ansible-playbook client-machine.yml`

运行完剧本后，您可以使用以下命令连接到客户端机器：

`docker exec -it client /bin/bash`

客户机应该在带有 kind 集群的`172.18.0.0/24`网络上（以及在Docker默认桥上）

## 易受攻击的集群

有一些剧本会带来具有特定错误配置的集群，这些配置可能会被利用。

- `etcd-noauth.yml` - ETCD 服务器可在无需认证的情况下访问
- `insecure-port.yml` - Kubernetes API 服务器的不安全端口可用
- `rwkubelet-noauth.yml` - Kubelet 读写端口可在无需认证的情况下访问
- `ssh-to-cluster-admin.yml` - 访问一个运行中的 pod，该 pod 使用的服务账户具有集群管理员权限。
- `ssh-to-create-daemonsets-hard.yml`
- `ssh-to-create-pods-easy.yml` - 访问一个运行中的 pod，该 pod 使用的服务账户具有管理 pod 的权限。
- `ssh-to-create-pods-hard.yml` - 访问一个运行中的 pod，该 pod 使用的服务账户具有创建 pod 的权限。
- `ssh-to-create-pods-multi-node.yaml`
- `ssh-to-get-secrets.yml` - 访问一个运行中的 pod，该 pod 使用的服务账户具有在集群级别获取 secret 的权限。
- `ssrf-to-insecure-port.yml` - 这个集群有一个带有 SSRF 漏洞的 web 应用，可以被利用来攻击不安全端口。
- `tiller-noauth.yml` - 配置了无需认证的 Tiller 服务。
- `unauth-api-server.yml` - API 服务器允许匿名访问敏感路径。
- `unauth-kubernetes-dashboard.yml` - 安装了 Kubernetes Dashboard 并且可以无需认证就访问的集群。
- `rokubelet.yml` - 暴露的只读 kubelet。这个还没有准备好（尚未！）的可攻击的路径。

如果您想选择一个随机场景来测试您的技能，请从项目文件夹中运行“get-random-scenario.sh”脚本！

## 使用集群

其中每一个都可用于尝试攻击Kubernetes集群的各种技术。一般来说，每个练习的目标应该是访问`/etc/kubernetes/pki/ca.key`文件，因为这是一个可以持久访问集群的[“金钥匙”](https://raesene.github.io/blog/2019/04/16/kubernetes-certificate-auth-golden-key/)

对于每个集群，开始的地方是在`Scenario Setups`中，其中包含如何开始的详细信息。

如果您想了解一些关于一个可能解决方案的信息，请查看`Scenario Walkthroughs`文件夹

## 清理

当您完成集群后，只需使用：

```bash
kind get clusters
```

要获取正在运行的集群列表，然后：

```bash
kind delete cluster --name=[CLUSTERNAME]
```

来删除 kind 集群，然后：

```bash
docker stop client
```

来删除客户端容器

## 演示设置

There's a specific pair of playbooks which can be useful for demonstrating Kubernetes vulnerabilities.  the `demo-cluster.yml` brings up a kind cluster with multiple vulnerabilities and the `demo-client-machine.yml` brings up a client container with the Kubernetes Kubeconfig for the demo cluster already installed.  For this pair, it's important to bring up the cluster before the client machine, so that the kubeconfig file is available to be installed.
