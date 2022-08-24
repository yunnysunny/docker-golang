ARG GO_VERSION
FROM golang:${GO_VERSION}

LABEL maintainer="yunnysunny@gmail.com"
ENV GO111MODULE on
ENV GOPROXY https://goproxy.cn,direct
ENV GOPRIVATE "gitlab.com"
ENV TZ Asia/Shanghai

# 安装依赖
RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
  && sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
  && apt-get --no-install-recommends update \
  && apt-get install git  -y \
  && rm -rf /var/lib/apt/lists/*
