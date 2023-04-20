#!/usr/bin/env python3

import os
from sys import argv
import git
try:
    git = git.Repo(argv[1]).git_dir
except git.exc.InvalidGitRepositoryError:
    print("Dir is non git")
    exit(1)


bash_command = ["cd "+argv[1], "git status"]
pwd = os.popen(bash_command[0]+";"+'pwd', 'r').read().replace('\n', '')
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(pwd+"/"+prepare_result)
