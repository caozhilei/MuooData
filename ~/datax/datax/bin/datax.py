#!/usr/bin/env python
# -*- coding:utf-8 -*-

import sys
import os
import signal
import subprocess
import time
import re
import socket
import json
from optparse import OptionParser
from optparse import OptionGroup
from string import Template
import codecs
import platform

def printCopyright():
    print('''
AllDataDC (%s), From AllDataDC !
AllDataDC All Rights Reserved.

''' % platform.system())
    sys.stdout.flush()

if __name__ == "__main__":
    printCopyright()
    abs_file=sys.path[0]
    json_file=sys.argv[1]
    log_name=sys.argv[2]
    
    # 获取DataX home目录（脚本所在目录的父目录）
    datax_home = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    
    # 设置Java路径（macOS）
    java_home = os.environ.get('JAVA_HOME', '/Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home')
    java_cmd = os.path.join(java_home, 'bin', 'java')
    
    # 构建DataX lib路径
    lib_path = os.path.join(datax_home, 'lib', '*')
    conf_path = os.path.join(datax_home, 'conf', 'logback.xml')
    log_path = os.path.join(datax_home, 'log')
    
    # 构建Java命令
    startCommand = '%s -server -Xms1g -Xmx1g -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=%s -Dloglevel=info -Dfile.encoding=UTF-8 -Dlogback.statusListenerClass=ch.qos.logback.core.status.NopStatusListener -Djava.security.egd=file:///dev/urandom -Ddatax.home=%s -Dlogback.configurationFile=%s -classpath %s -Dlog.file.name=%s_json com.alibaba.datax.core.Engine -mode standalone -jobid -1 -job %s > %s 2>&1' % (
        java_cmd,
        log_path,
        datax_home,
        conf_path,
        lib_path,
        os.path.basename(json_file).replace('.json', ''),
        json_file,
        log_name
    )
    
    print "执行命令: " + startCommand
    sys.stdout.flush()
    
    child_process = subprocess.Popen(startCommand, shell=True)
    (stdout, stderr) = child_process.communicate()
    
    sys.exit(child_process.returncode)

