#!/bin/sh
# Wrote by yijian on 2024/02/25
# 启动 etcd 的脚本

/root/etcd \
--listen-client-urls http://0.0.0.0:2379 \
--advertise-client-urls http://$NODE_IP:2379

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
