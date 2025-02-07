#!/bin/sh
#使用说明:https://github.com/GTian28/PTtool#readme
#结合du -b可以得到性能更快更好的版本，目前这个可用，先这样了


#查找文件硬链接
#ls -ialh file.txt
#find . -inum 1234

SRC="/share/Download/tmp/src"
DST="/share/Download/tmp/dst"

FILEGIG=1000000c

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

function servicectl_usage(){
  echo "Usage:mklink.sh sourcedir dstdir"
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
    exit -1
fi

#查找大于1M的文件，硬链接
for i in `find $SRC -size +$FILEGIG`
do

    echo "work:$i"

    if [ -d $i ]; then
        echo "跳过处理目录1:$i"
        echo "--"
        continue
        else if [ -e $i ]; then
        echo "src file:$i"
        fi
    fi
    
    #判断目录是否已经存在
    tmppth=`dirname $i`
    pth=${tmppth/"$SRC"/"$DST"}
    if [ ! -d $pth ]; then
        echo "mkdir -p $pth"
        mkdir -p $pth
    #else
    #    echo "跳过处理目录2:$i"
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
for i in `find $SRC -size -$FILEGIG`
do

    echo "work:$i"

    if [ -d $i ]; then
        echo "跳过处理目录3:$i"
        echo "--"
        continue
        else if [ -e $i ]; then
        echo "src file:$i"
        fi
    fi
    
    #判断目录是否已经存在
    tmppth=`dirname $i`
    pth=${tmppth/"$SRC"/"$DST"}
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

IFS=$SAVEIFS
