#!/bin/sh
 
echo 在备份库修改后，需要执行此脚本 将修改同步到原仓库

rm -rf src_rep
git clone git@gitee.com:bsn/proxy.git src_rep

echo 拉取最新的原仓库
pushd src_rep
git pull
git checkout .
git clean -fdx
git pull
popd

echo 删除原仓库所有文件
rm -rf src_rep/*
rm -rf src_rep/.gitmodules
rm -rf src_rep/.travis.yml

echo 将当前仓库内容打包
rm -rf src_rep.tar
git archive --format tar --output src_rep.tar master
echo 将当前仓库解包到原仓库
tar -xf src_rep.tar -C src_rep

echo 上传最新的原仓库
pushd src_rep
git submodule init
git submodule update
git add .
git commit -m "auto sync to src rep"
git push
popd