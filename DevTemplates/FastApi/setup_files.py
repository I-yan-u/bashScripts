#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 2024-12-13
Python package to setup FastApi project.
"""
import os
from pathlib import Path
import subprocess
import sys
import shutil


# Get OS
os_name = sys.platform
if os_name == 'win32':
    os_name = 'windows'
elif os_name == 'linux':
    os_name = 'linux'
else:
    os_name = 'mac'

# Shell type
OS_shell = 'powershell' if os_name == 'windows' else 'bash'

# Script path
base_path = Path(__file__).resolve().parent
script_path = f'{base_path}/create_env' if OS_shell == 'bash' else f'{base_path}/create_env.ps1'
create_app_file = f'{base_path}/create_app.txt'


# Directories
SERVER = 'server'

sub_dir = {
    'CONFIG' : f'{SERVER}/config',
    'CONTROLLERS' : f'{SERVER}/controllers',
    'MODELS' : f'{SERVER}/models',
    'SCHEMAS' : f'{SERVER}/schemas',
    'SERVICES' : f'{SERVER}/services',
    'REPOSITORIES' : f'{SERVER}/repositories',
    'UTILS' : f'{SERVER}/utils',
    'MIDDLEWARES' : f'{SERVER}/middlewares',
}

def mk_dirs():
    """
    Create directories
    """
    os.makedirs(SERVER, exist_ok=True)
    for d in sub_dir.values():
        os.makedirs(d, exist_ok=True)
        with open(f'{d}/__init__.py', 'w') as f:
            f.write('')
    print('Directories created successfully')


def setup_files():
    """
    Create files
    """
    # __init__ file
    with open(f'{SERVER}/__init__.py', 'w') as f:
        with open(create_app_file, 'r') as c:
            f.write(c.read())
    print('Main file created successfully')


def run_script(script_path, arg, shell_type="bash"):
    command = ["bash", script_path, arg] if shell_type == "bash" else \
              ["powershell", "-ExecutionPolicy", "Bypass", "-File", script_path, "-Arg1", arg]
    try:
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )

        # Print output line-by-line as it becomes available
        for line in iter(process.stdout.readline, ""):
            print(line, end="")

        # Wait for the process to complete
        process.stdout.close()
        process.wait()

        if process.returncode != 0:
            print("Error:", process.stderr.read())
    except Exception as e:
        print("Exception:", e)


def main(project_name: str):
    run_script(script_path, shell_type=OS_shell, arg=project_name)
    mk_dirs()
    setup_files()



# Run main function
if __name__ == '__main__':
    success = True
    while success:
        if len(sys.argv) <= 1:
            print('Project name required...')
            name = input('Project name > ')
            if name:
                success = False
                name = name.capitalize()
                main(name)
                break
        else:
            name = sys.argv[1].capitalize()
            main(name)
            break
