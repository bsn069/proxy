#!/bin/sh
 
echo 在本库修改后，需要执行此脚本 将已push的修改同步到备份仓库

bak_rep_git="git@github.com:bsn069/proxy.git"
bak_rep_git=$1
echo 备份仓库git地址 $bak_rep_git
des_rep_dir="tmp_bak_rep"
des_rep_dir="tmp_$2"
echo 备份仓库存放目录 $des_rep_dir 需要加到.gitignore

src_rep="tmp_this_rep"
echo 本仓库打包文件名 $src_rep
bak_git_rep_branch="master"
echo 备份的分支 $bak_git_rep_branch

echo 检测是否在目标库中 $bak_rep_git
cmdRet=`git remote -v | grep $bak_rep_git`
echo aa $cmdRet
if [[ $cmdRet != "" ]]
then
	echo 不允许在目标库执行
    exit 1
fi

if [ ! -d "$des_rep_dir" ]; then
    echo 目标库不存在，需要拉取
    git clone $bak_rep_git $des_rep_dir

    if [ ! -d "$des_rep_dir" ]; then
        echo 目标库拉取失败
        exit 1
    fi
fi

echo 更新目标库
pushd $des_rep_dir
git checkout $bak_git_rep_branch
git status
git checkout .
git clean -fdx
git pull
popd

echo 将当前仓库已push内容打包
rm -rf $src_rep.tar
git archive --format tar --output $src_rep.tar $bak_git_rep_branch

echo 创建解包目录$src_rep
if [ -d "$src_rep" ]; then
    echo 移除旧的目录$src_rep
    rm -rf $src_rep

    if [ -d "$src_rep" ]; then
        echo 移除旧的目录$src_rep 失败
        exit 2
    fi
fi
mkdir $src_rep
if [ ! -d "$src_rep" ]; then
    echo 目录$src_rep 创建失败
    exit 3
fi

echo 将目标库$des_rep_dir/.git 复制到$src_rep
cp -r $des_rep_dir/.git $src_rep/

echo 将当前仓库解包到$src_rep
tar -xf $src_rep.tar -C $src_rep

echo 上传最新的目标库$src_rep
pushd $src_rep
ls -ll
git status
git add .
git commit -m "auto bak"
git push
popd
