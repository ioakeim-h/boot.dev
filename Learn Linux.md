# Windows Subsystem for Linux (WSL) Setup Guide

## Install Ubuntu on WSL
1. **Run Windows Update** and restart your PC.
2. Open **Command Prompt (CMD)** as Administrator.
3. Install Ubuntu: `wsl --install -d Ubuntu`
4. Set up your **username** and **password** when prompted.
5. Restart your computer.
6. Verify installation: `wsl -l -v`
7. Launch Ubuntu from the Start Menu.

---

# Terminal and Shell Basics

## Key Concepts
- **Terminal**: Interface to input text commands and view output.
- **Shell** (Bash): Interpreter that executes commands (supports scripting).

### System Commands
| Command   | Description                  | Example             
|-----------|------------------------------|---------------------
| `history` | List command history         | `history`           
| `pwd`     | Show current directory       | `pwd`               
| `cd ~`    | Navigate to home directory   | `cd ~`         
| `cd /`    | Navigate to root directory   | `cd /`     

---

# File Operations

## Viewing Files
| Command | Description                  | Example                  
|---------|------------------------------|------------------------
| `cat`   | Display full file content    | `cat file.txt`          
| `head`  | Show first *n* lines         | `head -n 10 file.txt`   
| `tail`  | Show last *n* lines          | `tail -n 5 file.txt`    
| `less`  | Interactive paginated view   | `less -N file.txt`      

**Less Controls**:
- `Space` = Next page  
- `b` = Previous page  
- `q` = Quit  

## File Management
| Command | Description                  | Example                 
|---------|------------------------------|-------------------------
| `touch` | Create/update file timestamp | `touch new_file.txt`    
| `rm`    | Delete files/dirs            | `rm file.txt`           
| `rm -r` | Delete dirs recursively      | `rm -r dir/`           
| `cp`    | Copy files                   | `cp file.txt dest/`     
| `cp -R` | Copy dirs recursively        | `cp -R dir/ new_dir/`  


## Text Search with `grep`

### Basic Usage
```bash
grep "hello" file.txt       # Case-sensitive search
grep -i "hello" file.txt    # Case-insensitive
grep -r "hello" .           # Recursive (current dir + subdirs)
```

### Advanced
- Search **multiple files**:
  ```bash
  grep "hello" file1.txt file2.txt
  ```
- Show **line numbers**:
  ```bash
  grep -n "hello" file.txt
  ```

## Find files by name with `find`

### Basic Usage
```bash
find some_directory -name hello.txt   # File names equal to hello.txt
find some_directory -name "*.txt"     # File names ending with ".txt"
find some_directory -name "*chad*"    # File names including the word "chad"
```

---

# File Permissions

## Understanding the 10-Character String
Linux file permissions are represented by a 10-character string that appears at the beginning of a file listing when using `ls -l`. This string defines access rights for three categories of users: owner, group, and others.

## The 10-Character Permission String
```
-rwxr-xr--
│└─┬──┴─┬──┴─┬──
│  │    │    │
│  │    │    └─ Permissions for others (world)
│  │    └────── Permissions for group
│  └─────────── Permissions for owner
└────────────── File type indicator
```

### 1. First Character: File Type
- `-` Regular file
- `d` Directory

### 2. Characters 2-4: Owner Permissions
- `r` Read permission
- `w` Write permission
- `x` Execute permission
- `-` Permission not granted

### 3. Characters 5-7: Group Permissions
- Same as owner permissions

### 4. Characters 8-10: Others Permissions
- Same as owner permissions

## Permission Types Explained

| Character | Permission | Effect on Files | Effect on Directories 
|-----------|------------|-----------------|-----------------------
| `r`       | Read       | View file contents | List directory contents 
| `w`       | Write      | Modify file contents | Create/delete files in directory 
| `x`       | Execute    | Run as program | Access (cd into) directory 
| `-`       | None       | No permission | No permission 

## Viewing and Modifying Permissions

- View permissions: `ls -l filename`
- Change permissions: `chmod [options] file`
- Change owner: `chown [options] user:file`
- Change group: `chgrp [options] file`

**Examples**

1. Set full permissions (read, write, execute) for the owner (user) and no permissions for group/others on a directory (recursively):
`chmod -R u=rwx,g=,o= path/to/dir`

2. Remove execute (x) permission for all users on a file:
`chmod -x path/to/file`

3. Add execute (x) permission back for the owner (user) only:
`chmod u+x path/to/file`

4. Change directory owner to root using sudo
`sudo chown -R root path/to/dir`

---

# Programs

## Compiled vs Interpreted

Compiled programs are transformed from human-readable source code into binary executables. For example, Go programs are compiled into standalone binaries that can be run directly from the shell.

Interpreted programs require an interpreter to run. Instead of being compiled ahead of time, they are executed line-by-line by another program, such as Python or Bash.

Compiled executables can be run by typing their file path into a shell. Interpreted scripts, however, need the system to know which interpreter to use. This can be specified explicitly (e.g., `python3 script.py`) or through a shebang.

A **shebang** is a special line at the top of a script that tells the shell which interpreter to use. Its format is: `#! interpreter [optional-arg]`
Shebang example for Python 3: `#!/usr/bin/python3`

With a shebang and executable permission (`chmod +x script.py`), the script can be run directly, without referring the interpreter: `./script.py`

## Variables

Shell supports both local and global (environment) variables. 

```bash
name="Ioakeim"          # local var
export NAME="Ioakeim"   # global var
```

Environment variables can be viewed using the `env` command. They persist for the duration of the shell session and are accessible to all programs launched from that shell. For example, we can create a file called `introduce.sh` with the following contents:

```bash
#!/bin/sh
echo "Hi I'm $NAME"
```

Then run it:

```bash
chmod +x ./introduce.sh

./introduce.sh
# Hi I'm Ioakeim
```

### PATH

The `PATH` variable is a built-in environment variable that contains a list of directories. When you type a command, the shell searches these directories in order to find the corresponding executable. As shown by `echo $PATH`, each directory in the variable is separated by a colon (`:`).

Often, a “command not found” error (assuming no syntax issues) means the program is installed in a directory not listed in your `PATH`. To fix this for the current shell session, add the directory’s **absolute path** to the `PATH` variable:
`export PATH="$PATH:/path/to/new"`

This will update the `PATH` variable for the current shell session only. The next time you restart your shell, `PATH` will be reset to its default value. To change your `PATH` variable permanently, add the same export command to your shell's configuration file:
1. `PATH` is set during shell startup by config files like `.bashrc` (for WindowsOS) or `.zshrc` (for MacOS). The config file is likely hidden at the home directory and can be listed with the command `ls -a ~`.
2. Navigate to the home directory and open the file using `nano .bashrc`. Add the export command to the end of the file.
3. Press CRTL + O, then press Enter and CRTL + X to exit.

Troubleshooting: 
* Ensure you use the absolute path without a trailing slash. The final result should look something like this: 
`export PATH="$PATH:/home/ihadjimpalasis/worldbanc/private/bin"`
* When working in WSL and accessing Windows files from the shell, you must include `/mnt`, the mount point for Windows drives, in the path. For example, `C:\` in Windows becomes `/mnt/c/` in WSL.

---

# Input/Output

## The `man`

`man` stands for "manual" and is used to look up usage details or special flags for commands. For example, `man grep` opens the manual for the `grep` command.
While viewing a manual:
* Press `/` and type a search term to find it (e.g., `/-v,` looks for the `-v` flag)
* Press `n` to jump to the next match
* Press `N` to go to the previous match
* Press the spacebar to scroll down one page
* Press `b` to go back one page


## Flags

Flags are options that you can pass to a command to change its behavior. Whether or not a command takes flags, and what those flags are, is up to the developer of the command. That said there are some common conventions:
* Single-character flags are prefixed with a single dash (.e.g `-a`)
* Multi-character flags are prefixed with two dashes (e.g. `--help`)
* Sometimes the same flag can be used with a single dash or two dashes (e.g. `-h` or `--help`)


## Exit codes

Exit codes are how programs communicate back whether they ran successfully or not. Commands will usually exit with error codes if they've been run without the proper arguments or configuration. **0 is the exit code for success. Any other exit code is an error.**

In a shell, you can access the exit code of the last program you ran with the question mark variable (`$?`). For example, if you run a program that exits with a non-zero exit code, you can see what it was with the echo command: `echo $?`


## stdin, stdout, stderr

**Standard Output (stdout)** is the default stream where programs write their output.  
**Standard Error (stderr)** is a separate stream used for error messages.  
**Standard Input (stdin)** is the default stream from which programs read input.

You can redirect these streams:
- `>` redirects stdout  
- `2>` redirects stderr  

```bash
echo "Hello world" > hello.txt
cat hello.txt
# Hello world
```

```bash
cat doesnotexist.txt 2> error.txt
cat error.txt
# cat: doesnotexist.txt: No such file or directory
```

Use stdin for user input:
```bash
read NAME   # ioakeim
echo $NAME
# ioakeim
```

## Pipe operator

The pipe operator `|` takes the stdout of the program on the left and "pipes" it into the stdin of the program on the right. This works with shell commands that can read from stdin: 
```bash
echo "Have you heard the tragedy of Darth Plagueis the Wise?" | wc -w
# 10
```

## Interrupt and Kill

Sometimes a program gets stuck. Press `Ctrl + C` to stop it. This sends a **SIGINT** (interrupt signal). If the program ignores SIGINT, use a new terminal to kill it manually: `kill <PID>`

Find the process ID (PID) using the process status command (`ps`):
```bash
ps aux # shows all processes
```

## Top

The `top` command is a powerful tool that allows you to see which programs are using the most resources on your computer. By default, `top` sorts the processes by `%CPU` usage, with the most CPU-intensive processes at the top. Another useful resource to sort by is RAM (`%MEM`) usage. To sort by memory usage, press `M` (uppercase) while `top` is running.


# Packages

## APT

APT, or "Advanced Package Tool", is the primary package manager for Ubuntu. You can install software with it.
```bash
sudo apt update             # update apt
sudo apt install neovim     # install neovim
```

## WSL in VSCode

1. Open VS Code and navigate to the "Extensions" menu on the left-hand toolbar.
2. Search for "WSL" and install the extension created by Microsoft.
3. In the very bottom-left corner of VS Code, there should be a green or blue button. Click on that and select "Connect to WSL using Distro" and select "Ubuntu".

I recommend pinning this new window to your task-bar so that you can always open the WSL-enabled version of VS Code in one click. 
