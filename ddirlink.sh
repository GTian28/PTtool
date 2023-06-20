#!/bin/bash
#记录日志: ./dirlink.sh > dirlink.log
#使用说明: https://github.com/GTian28/PTtool#readme

#查找文件硬链接
#ls -ialh file.txt
#find . -inum 1234

#最后面不要加斜杠
SRC="/volume1/media/src"
DST="/volume1/media/dst"

FILEGIG=1000000c

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
######################################

function mklink() {
    local THISSRC=$1
    local THISDST=$2
    echo "mklink:"$THISSRC $THISDST

    #查找大于1M的文件，硬链接
    for i in `find $THISSRC -size +$FILEGIG`
    do

        echo "work:$i"

        if [ -d $i ]; then
            echo "跳过处理目录:$i"
            echo "--"
            continue
            else if [ -e $i ]; then
            echo "THISSRC file:$i"
            fi
        fi
        
        #判断目录是否已经存在
        tmppth=`dirname $i`
        pth=${tmppth/"$THISSRC"/"$THISDST"}
        if [ ! -d $pth ]; then
            echo "mkdir -p $pth"
            mkdir -p $pth
        #else
        #    echo "跳过处理目录:$i"
        #    echo "--"
        #    continue
        fi
        
        dstfile=$pth/`basename $i`
        echo "dst file:${dstfile}"
        
        #判断文件是否已经存在
        #不存在才复制
        if [ ! -f $dstfile ]; then
          echo "cp -l $i $dstfile"
          cp -l $i $dstfile
        fi
        
        echo "--"

    done



    #查找小于1M的文件，复制小于1m的文件
    for i in `find $THISSRC -size -$FILEGIG`
    do

        echo "work:$i"

        if [ -d $i ]; then
            echo "跳过处理目录:$i"
            echo "--"
            continue
            else if [ -e $i ]; then
            echo "src file:$i"
            fi
        fi
        
        #判断目录是否已经存在
        tmppth=`dirname $i`
        pth=${tmppth/"$THISSRC"/"$THISDST"}
        if [ ! -d $pth ]; then
          echo "mkdir -p $pth"
          mkdir -p $pth
        fi
        
        dstfile=$pth/`basename $i`
        echo "dst file:${dstfile}"
        
        #判断文件是否已经存在
        #不存在才复制
        if [ ! -f $dstfile ]; then
          echo "cp $i $dstfile"
          cp $i $dstfile
        fi
        
        echo "--"

    done

    return 0
}

function servicectl_usage(){
  echo "Usage:dirlink.sh sourcedir dstdir"
  return 1 
}

function servicectl(){
[[ -z $1 || -z $2 ]] && servicectl_usage
}

if [ $# -eq 2 ]; then
    SRC=$1
    DST=$2
    echo "User set:"
    echo "src:$SRC"
    echo "dst:$DST"
else
    servicectl_usage
    echo "use default set:"
    echo "源目录src:$SRC"
    echo "目的目录dst:$DST"
fi

function check_dir() {
    local current_dir=$1
    for file in "$current_dir"/*; do
        if [ -f "$file" ]; then
            local link_count=$(ls -l "$file" | awk '{print $2}')
            if [ "$link_count" -eq 1 ]; then
                # 找到一个没有硬链接的文件，不删除目录
                return 1
            fi
        fi
    done
    # 没有找到没有硬链接的文件，删除目录
    rm -r "$current_dir"
    return 0
}

# 创建新的函数，用于递归遍历目录
function recursive_mklink() {
    local current_dir=$1
    local target_dir=$2

    # 遍历当前目录下的所有文件和子目录
    for item in "$current_dir"/*; do
        # 如果是目录，就递归调用这个函数
        if [ -d "$item" ]; then
            recursive_mklink "$item" "$target_dir/$(basename "$item")"
        fi
    done

    # 检查目录下是否有文件，如果有，就调用mklink函数
    local dir_has_file=$(find "$current_dir" -maxdepth 1 -type f | head -1)
    if [ -n "$dir_has_file" ]; then
        if [ -e "$current_dir/islinked.lk" ]; then
            check_dir "$current_dir"
        else
            mklink "$current_dir" "$target_dir"
            touch "$current_dir/islinked.lk"
        fi
    fi
}

# 调用递归函数
recursive_mklink "$SRC" "$DST"

IFS=$SAVEIFS
