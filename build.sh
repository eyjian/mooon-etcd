#!/bin/bash
# Wrote by yijian on 2024/02/24
# 制作 etcd 的镜像
# 参考：https://github.com/etcd-io/etcd/releases
# 本镜像用于测试

ETCD_VER="v3.5.12" # etcd 版本
BASE_IMAGE=`echo "${BASE_IMAGE:-}"` # 指定基础镜像（要求 64 位 AMD64 Linux）
MAINTAINER=`echo "${MAINTAINER:-}"` # 镜像维护者
IMAGE_REPO=`echo "${IMAGE_REPO:-}"` # 镜像仓库（制作好的 etcd 镜像将放在这里）

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

# IMAGE_REPO
if test -z "$IMAGE_REPO"; then
    echo "Variable IMAGE_REPO is not set, example: export IMAGE_REPO=\"cr.console.aliyun.com\""
    exit 3
fi
echo "IMAGE_REPO: $IMAGE_REPO"

set -e

# 删除已存在的
rm -f $WORK_DIR/etcd-${ETCD_VER}-linux-amd64.tar.gz

# 下载二进制包并解压
curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o $WORK_DIR/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzf $WORK_DIR/etcd-${ETCD_VER}-linux-amd64.tar.gz -C $WORK_DIR --strip-components=1

# 删除二进制包
rm -f $WORK_DIR/etcd-${ETCD_VER}-linux-amd64.tar.gz

# 检查是否可用
$WORK_DIR/etcd --version
$WORK_DIR/etcdctl version
$WORK_DIR/etcdutl version

# 生成 Dockerfile 文件
rm -f $WORK_DIR/Dockerfile
echo "FROM $BASE_IMAGE" >> $WORK_DIR/Dockerfile
echo "MAINTAINER $MAINTAINER" >> $WORK_DIR/Dockerfile
echo "" >> $WORK_DIR/Dockerfile
echo "WORKDIR /root/" >> $WORK_DIR/Dockerfile
echo "COPY $WORK_DIR/etcd /root/" >> $WORK_DIR/Dockerfile
echo "COPY $WORK_DIR/etcdctl /root/" >> $WORK_DIR/Dockerfile
echo "COPY $WORK_DIR/etcdutl /root/" >> $WORK_DIR/Dockerfile
echo "" >> $WORK_DIR/Dockerfile
echo "ENTRYPOINT [\"/root/etcd\"]" >> $WORK_DIR/Dockerfile
# 注意 advertise-client-urls 的值不能为 http://0.0.0.0:2379，
# 需为一个可对外的地址，如果只本地使用，可设置为 http://127.0.0.1:2379，
# 实际中可使用环境变量 NODE_IP 的值。
echo "CMD [\"--listen-client-urls\",\"http://0.0.0.0:2379\",\"--advertise-client-urls\",\"http://127.0.0.1:2379\"]" >> $WORK_DIR/Dockerfile

# 构建镜像
CMD="docker build -t $IMAGE_REPO/etcd:${ETCD_VER} ."
echo "$CMD"
sh -c "$CMD"

# 确认是否推送镜像
echo -ne "Do you want to push etcd:${ETCD_VER} to $IMAGE_REPO"
read -p " (yes or no) : " choice
if test "X$choice" != "Xyes"; then
    exit 4
fi

# 推送镜像
CMD="docker push $IMAGE_REPO/etcd:${ETCD_VER}"
echo "$CMD"
sh -c "$CMD"

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
