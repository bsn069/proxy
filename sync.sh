#!/bin/sh

#!/bin/sh

echo 触发git同步到备份仓库

cmdRet=$(git remote -v | grep "gitee")
if [ cmdRet == "" ]; then
    echo 不允许在备份仓库执行
    exit 1
fi

git checkout master
git pull
git submodule update
echo 确保有文件变更，可以推送到仓库
date > deploy_ver.txt
git status
git add .
git commit -m "只是为了触发仓库同步"
git push
 
echo 由此库触发的自动同步
pushd tdm_git_sync
sh sync.sh
popd