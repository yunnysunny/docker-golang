# go 私有包编译工具镜像

一个支持构建 go 私有项目的 docker 镜像，里面包含 go 的 runtime 和 gcc g++ 等原生编译工具。使用此镜像，跟直接在宿主机上构建相比，有如下优势：不同版本的 go runtime 可以通过不同 docker tag 相互隔离，这样可以在一台宿主机上按需选择不同的版本的 runtime 构建所需项目；可以更好的支持镜像构建自动化，通过 dockerfile 的构建阶段特性，可以将当前镜像编译成功的二进制文件直接拷贝到下一构建阶段，这样对于 CI 来说更为友好。

当前代码中支持的私有仓库为 gitlab.com，如果是自己构建的 gitlab 仓库，需要修改 Dockerfile 中 GOPRIVATE 环境变量。

## 1 使用方法

### 1.1 私有包配置

本镜像目前只支持通过 gitlib.com 下的私有包。对于开发者来说，如果想引用其他仓库私有包，需要修改 Dockerfile 中的 GOPRIVATE 环境变量。关于私有包配置的其他问题，可以参阅我的博文 [go 私有化包构建路](https://blog.whyun.com/posts/go-private-package/) 。

### 1.2 dockerfile 编写

#### 1.2.1 将生成二进制导出到本地

```dockerfile
FROM yunnysunny/golang:latest AS build-stage

RUN mkdir -p /var/app /data/src /data/bin
COPY src /data/src

WORKDIR /data/src
RUN go mod tidy && go build -o ../bin/micro

FROM scratch AS export-stage
COPY --from=build-stage /data/bin/micro /
```

**代码 1.2.1.1 bin.Dockerfile**

使用命令 `DOCKER_BUILDKIT=1 docker build --file bin.Dockerfile --output bin .` 可以将 **代码 1.2.1.1** 生成的二进制导出到当前目录的 bin 子文件夹中。


#### 1.2.2 将生成二进制拷贝到下一阶段


```dockerfile
FROM yunnysunny/golang:latest AS build-stage

RUN mkdir -p /data/src /data/bin
COPY src /data/src

WORKDIR /data/src
RUN go mod tidy && go build -o ../bin/micro

# 这个 ENV_IMAGE 要替换成具体的一个镜像名，比如说 ubuntu:latest ，否则无法运行
FROM ${ENV_IMAGE} AS env-stage

RUN mkdir -p /var/app
WORKDIR /var/app
COPY --from=build-stage /data/bin/micro micro
```

**代码 1.2.2.1 app.Dockerfile**

使用命令 `docker build -f app.Dockerfile .` 即可生成一个包含编译生成二进制的镜像，`${ENV_IMAGE}` 镜像中不包含运行时环境，可以从一定程度上节省构建出来的镜像体积。 


