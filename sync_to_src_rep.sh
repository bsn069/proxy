#!/bin/sh
 
echo 在备份库修改后，需要执行此脚本 将修改同步到原仓库

src_rep_git="git@gitee.com:bsn/proxy.git"
echo 原仓库git地址 $src_rep_git
git_submodule_1="tdm_git_sync"
echo 子模块1 $git_submodule_1

src_rep_name="tmp_src_rep"
echo 原仓库存放目录 $src_rep_name
this_rep_pkg_name="tmp_this_rep"
echo 本仓库打包文件名 $this_rep_pkg_name
sync_git_rep_branch="master"
echo 同步分支 $sync_git_rep_branch
 
if [ ! -d "$src_rep_name" ]; then
    echo 原仓库不存在，需要拉取
    git clone $src_rep_git $src_rep_name

    if [ ! -d "$src_rep_name" ]; then
        echo 原仓库拉取失败
        exit 1
    fi
fi

echo 更新原仓库
pushd $src_rep_name
git checkout .
git clean -fdx
git pull
popd

echo 将当前仓库内容打包
rm -rf $this_rep_pkg_name.tar
git archive --format tar --output $this_rep_pkg_name.tar $sync_git_rep_branch

if [ -d "$this_rep_pkg_name" ]; then
    echo 移除旧的目录$this_rep_pkg_name
    rm -rf $this_rep_pkg_name

    if [ -d "$this_rep_pkg_name" ]; then
        echo 移除旧的目录$this_rep_pkg_name 失败
        exit 2
    fi
fi
echo 创建解包目录$this_rep_pkg_name
mkdir $this_rep_pkg_name
if [ ! -d "$this_rep_pkg_name" ]; then
    echo 目录$this_rep_pkg_name 创建失败
    exit 3
fi

echo 将原仓库$src_rep_name/.git 复制到$this_rep_pkg_name
cp -r $src_rep_name/.git $this_rep_pkg_name/

echo 还原子模块
pushd $this_rep_pkg_name/
git checkout -- $git_submodule_1
popd
 
echo 将当前仓库解包到$this_rep_pkg_name
tar -xf $this_rep_pkg_name.tar -C $this_rep_pkg_name
exit 0

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

exit
echo 上传最新的原仓库
pushd src_rep
git submodule init
git submodule update
git add .
git commit -m "auto sync to src rep"
git push
popd