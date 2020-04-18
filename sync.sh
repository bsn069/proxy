#!/bin/sh

echo 在原仓库执行，触发自动构建，将git同步到备份仓库

src_git_url=git@gitee.com:bsn/proxy.git
echo 原仓库地址src_git_url=$src_git_url
src_git_branch=master
echo 原仓库分支src_git_branch=$src_git_branch

cmdRet=`git remote -v | grep "$src_git_url"`
echo cmdRet=[${cmdRet}]
if [ "$cmdRet" == "" ]; then
    echo 不在原仓库，禁止执行
    exit 1
fi

cmdRet=`git branch | grep "\* $src_git_branch"`
echo cmdRet=[${cmdRet}]
if [ "$cmdRet" == "" ]; then
    echo 不在原仓库分支$src_git_branch，禁止执行
    exit 2
fi

if [ ! -d "tdm_git_sync" ]; then
    echo 用来触发自动构建的子模块不存在
    exit 3
fi

git pull
echo 确保有文件变更，可以推送到仓库
date > deploy_ver.txt
git status
git add --all
git commit -m "只是为了触发仓库同步"
git push
 
echo 由此库触发的自动同步
pushd tdm_git_sync
sh sync.sh
popd