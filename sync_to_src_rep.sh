#!/bin/sh
 
echo 在备份库修改后，需要执行此脚本 将修改同步到原仓库


git clone git@gitee.com:bsn/proxy.git src_rep

pushd src_rep
git checkout .
git clean -fdx
git pull
popd

echo 删除原仓库所有文件
rm -rf src_rep/*
rm -rf src_rep/.

echo 将当前仓库内容打包
git archive --format tar --output src_rep.tar master
echo 将当前仓库解包到原仓库
tar -xf src_rep.tar -C src_rep