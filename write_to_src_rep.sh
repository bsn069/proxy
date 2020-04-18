#!/bin/sh
 
echo 在备份库修改后，需要执行此脚本 将已push的修改同步到原仓库

src_rep_git="git@gitee.com:bsn/proxy.git"
echo 原仓库git地址 $src_rep_git
git_submodule_1="tdm_git_sync"
echo 子模块1 $git_submodule_1

src_rep_name="tmp_src_rep"
echo 原仓库存放目录 $src_rep_name 需要加到.gitignore
this_rep_pkg_name="tmp_this_rep"
echo 本仓库打包文件名 $this_rep_pkg_name
sync_git_rep_branch="master"
echo 同步分支 $sync_git_rep_branch

echo 检测是否在原git库 $src_rep_gi
cmdRet=`git remote -v | grep $src_rep_git`
if [ "$cmdRet" != "" ]; then
	echo 不允许在原库执行同步到原的操作
    exit 1
fi

if [ ! -d "$src_rep_name" ]; then
    echo 原仓库不存在，需要拉取
    git clone $src_rep_git $src_rep_name

    if [ ! -d "$src_rep_name" ]; then
        echo 原仓库拉取失败
        exit 1
    fi

    echo 初始化原仓库子模块
    pushd $src_rep_name
        git submodule init
        git submodule update
        git submodule foreach git checkout $sync_git_rep_branch
    popd
fi

echo 更新原仓库
pushd $src_rep_name
git status
git checkout .
git clean -fdx
git checkout $sync_git_rep_branch
git pull
popd

echo 将当前仓库已push内容打包
rm -rf $this_rep_pkg_name.tar
git archive --format tar --output $this_rep_pkg_name.tar $sync_git_rep_branch

echo 创建解包目录$this_rep_pkg_name
if [ -d "$this_rep_pkg_name" ]; then
    echo 移除旧的目录$this_rep_pkg_name
    rm -rf $this_rep_pkg_name

    if [ -d "$this_rep_pkg_name" ]; then
        echo 移除旧的目录$this_rep_pkg_name 失败
        exit 2
    fi
fi
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
git submodule foreach git checkout $sync_git_rep_branch
popd
 
echo 将当前仓库解包到$this_rep_pkg_name
tar -xf $this_rep_pkg_name.tar -C $this_rep_pkg_name

echo 上传最新的原仓库$this_rep_pkg_name
pushd $this_rep_pkg_name
ls -ll
git status
git add --all
git commit -m "从备份仓库同步到原仓库"
git push
popd
 
echo 删除中间文件
rm -rf $this_rep_pkg_name.tar
rm -rf $this_rep_pkg_name
 