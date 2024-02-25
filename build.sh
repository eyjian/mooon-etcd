#!/bin/bash
# Wrote by yijian on 2024/02/24
# 制作 etcd 的镜像
# 参考：https://github.com/etcd-io/etcd/releases
# 本镜像用于测试

ETCD_VER="v3.5.12" # etcd 版本
BASE_IMAGE=`echo "${BASE_IMAGE:-}"` # 指定基础镜像（要求 64 位 AMD64 Linux）
MAINTAINER=`echo "${MAINTAINER:-}"` # 镜像维护者

# 设置下载的 URL
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GITHUB_URL}
WORK_DIR=. # 在哪个目录下制作镜像

# BASE_IMAGE
if test -z "$BASE_IMAGE"; then
    echo "Variable BASE_IMAGE is not set, example: export BASE_IMAGE=\"hub.docker.com/centos:centos8\""
    exit 1
fi
echo "BASE_IMAGE: $BASE_IMAGE"

# MAINTAINER
if test -z "$MAINTAINER"; then
    echo "Variable MAINTAINER is not set, example: export MAINTAINER=\"yijian<eyjian@qq.com>\""
    exit 2
fi
echo "MAINTAINER: $MAINTAINER"

set -e

# 删除已存在的
rm -f $WORK_DIR/etcd-${ETCD_VER}-linux-amd64.tar.gz

# 下载二进制包并解压
curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o $WORK_DIR/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C $WORK_DIR --strip-components=1

# 删除二进制包
rm -f $WORK_DIR/etcd-${ETCD_VER}-linux-amd64.tar.gz

# 检查是否可用
$WORK_DIR/etcd --version
$WORK_DIR/etcdctl version
$WORK_DIR/etcdutl version

# 生成 Dockerfile 文件
rm -f $WORK_DIR/Dockerfile
echo "FROM $BASEIMAGE" >> $WORK_DIR/Dockerfile
echo "MAINTAINER $MAINTAINER" >> $WORK_DIR/Dockerfile

echo "" >> $WORK_DIR/Dockerfile

echo "WORKDIR /root/" >> $WORK_DIR/Dockerfile
echo "COPY $WORK_DIR/etcd /root/" >> $WORK_DIR/Dockerfile
echo "COPY $WORK_DIR/etcdctl /root/" >> $WORK_DIR/Dockerfile
echo "COPY $WORK_DIR/etcdutl /root/" >> $WORK_DIR/Dockerfile

echo "" >> $WORK_DIR/Dockerfile

echo "ENTRYPOINT [\"/root/etcd\"]" >> $WORK_DIR/Dockerfile

set +e

# 官方示例：
#/usr/local/bin/etcd \
#  --name s1 \
#  --data-dir /etcd-data \
#  --listen-client-urls http://0.0.0.0:2379 \
#  --advertise-client-urls http://0.0.0.0:2379 \
#  --listen-peer-urls http://0.0.0.0:2380 \
#  --initial-advertise-peer-urls http://0.0.0.0:2380 \
#  --initial-cluster s1=http://0.0.0.0:2380 \
#  --initial-cluster-token tkn \
#  --initial-cluster-state new \
#  --log-level info \
#  --logger zap \
#  --log-outputs stderr
