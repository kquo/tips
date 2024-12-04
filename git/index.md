# git
Version control tips with `git` and <https://github.com>.


## Remove Branches
```
git branch -d MY_BRANCH                      # Delete local MY_BRANCH
git push origin :MY_BRANCH                   # Delete remote MY_BRANCH
git remote prune origin --dry-run            # Confirm which branches have been removed from remote
git remote prune origin                      # Remove them from local
```


## Basic Usage
```
git checkout MASTER-BRANCH                   # Checkout the canonical source
git pull --rebase                            # Ensure most recent changes are in
git checkout -b MY_BRANCH                    # Create a local branch
git push --set-upstream origin MY_BRANCH     # Push it to origin, to work from it
git config --global push.default current     # To automatically do above henceforth
... Now make all your needed changes
git add .                                    # Add your changes
git commit -m "my changes"                   # Commit your changes
... Create a pull request (PR) via the web UI, have it peer-review, then merge it
```


## General
```
git diff branch_A branch_B                   # Compare two branches
git config user.email <email>
git clone git@github.com:Org/MyRepo.git      # Clone via SSH
git clone https://github.com/Org/MyRepo.git  # Clone via HTTPS
git clone /data/tech/code/trix.git trix      # Clone bare local repo (in iCloud, etc)

git pull                                     # Pick up recent changes from master
git add .                                    # Update local repo with all recent changes (b4 committing)
git commit -m "message"                      # Commit all recent changes to current branch (local copy)
git push                                     # Commit your local copy to OFFICIAL master branch

git branch -a                                # Display all branches
git checkout branchA                         # Switch to branch 'branchA'
git log -p                                   # Show full description of recent commits
git log --pretty=oneline                     # Show prettified recent comments

git checkout SOURCE -- FILE/PATH/HERE        # Bring FILE/PATH/HERE from SRC to current branch         
git checkout SOURCE -- .                     # Bring all the files from SRC to current branch         
git diff --stat=140 main                     # Great view comparison of current branch to main
git branch --contains GITHASH                # Search For Specific Hash Across Branches

git mergetool                                      # Resolve Conflicts
git config --global credential.helper osxkeychain  # Store Credentials on macOS Keychain
```

## Switch from master to main
```
git branch -m master main
git push -u origin main
# Now go to the SCM UI and change to main branch
git push origin --delete master
```


## Fork and Sync Repositories
```
git remote -v                                               # List the current remotes
git remote add upstream https://github.com/user/repo        # Add remote upstream of fork
git remote set-url --push upstream DISABLE                  # Disable pushes for above (since you can't anyway)
git checkout master                                         # Ensure you're on your fork's master branch
git fetch upstream                                          # fetch upstream branches
git merge upstream/master                                   # Merge upstream master
git push
```


## Additional Origins
```
git remote set-url origin git@github.com:user/repo2             # Replace origin
git remote set-url --add origin https://github.com/user/repo3   # Add another origin
```


## Squash Commits
Squash or clump commits by moving to a new branch:

```
   git checkout OLD_BRANCH
   git diff main > ../changes.diff
   git checkout main
   git pull
   git checkout -b NEW_BRANCH
   git apply ../changes.diff
   git commit -m "Squashed OLD_BRANCH changes"
   git push
   # Delete OLD_BRANCH locally and remotely
```


## Revert to a Previous Commit
When you absolutely need to revert last commits.

* **Warning**: Know what you're doing. There's no way back.
* RECENT VERSIONS OF `git` HAVE EASIER WAY OF DOING THIS.

```
git reset --hard HEAD~1  # Change '1' to '2' or however many commits you want to revert back
git push -f

# Below has also worked well, for LAST commit
git reset --hard [previous Commit SHA id here] # Use --soft to keep your changes
git push origin [branch Name] -f
```


## Create new Git Origin Repo, Local or Remote
```
# Populate myproject directory with initial required files to be commited
cd myproject
git init
git add .
git commit -m "First commit"
# Create local origin directory (preferably a cloud drive) and PUSH to it
mkdir -p ~/data/tech/gitrepos/myproject.git
git init --bare ~/data/tech/gitrepos/myproject.git
git remote set-url origin ~/data/tech/gitrepos/myproject.git
git remote -v   # To confirm where origin is
git push
# OR create GitHub remote origin and PUSH to it
# Manually create bare repo in Github via Web UI
git remote add origin git@github.com:username/myproject
git remote -v   # To confirm where origin is
git push
```


## Tags
```
git tag                                 # List tags
git tag -l "v1.8.5*"                    # Search tags
git tag -a v1.4 -m "my version 1.4"     # Create/annotate a tag
git tag -a v1.2 9fceb02                 # Tag existing commit
git push origin v1.5                    # Share tag by pushing to origin
git push origin --tags                  # Share all tags
git checkout tags/v2.0.0 -b NEW_BRANCH  # Create new branch from a tag
git tag -d v2.0.0                       # Delete a tag locally ...
git push origin :refs/tags/v2.0.0       # ... and remotely
```


## Markdown Choice List
```
    * [ ] Is it still in use?
    * [ ] Should it be maintained and kept active?
    * [ ] Should it be archived for future reference?
    * [ ] Or should it just be deleted with no trace left behind?
```


## List Repos Using Github Token:
```
curl -u lencap:TOKEN https://api.github.com/orgs/:ORGNAME/repos?type=private
```


## Show Branch in Shell Prompt
To show current git branch in BASH PS1 prompt, do the following: 

1. Create this `~/.fast-git-prompt.sh` script: 

```bash
# Copyright (c) 2019 Will Bender. All rights reserved.

# This work is licensed under the terms of the MIT license.
# For a copy, see <https://opensource.org/licenses/MIT>.

# Very fast __git_ps1 implementation
# Inspired by https://gist.github.com/wolever/6525437
# Mainly this is useful for Windows users stuck on msys, cygwin, or slower wsl 1.0 because git/fs operations are just slower
# Caching can be added by using export but PROMPT_COMMAND is necessary since $() is a subshell and cannot modify parent state.
# Linux: time __ps1_ps1 (~7ms)
# Windows msys2: time __git_ps1 (~100ms)
# Windows msys2: time git rev-parse --abbrev-ref HEAD 2> /dev/null (~86ms)
# Windows msys2: time __fastgit_ps1 (~1-3ms)

# Simple PS1 without colors using format arg. Feel free to use PROMPT_COMMAND
export PS1="\u@\h \w \$(__fastgit_ps1 '[%s] ')$ "

# 100% pure Bash (no forking) function to determine the name of the current git branch
function __fastgit_ps1 () {
    local headfile head branch
    local dir="$PWD"

    while [ -n "$dir" ]; do
        if [ -e "$dir/.git/HEAD" ]; then
            headfile="$dir/.git/HEAD"
            break
        fi
        dir="${dir%/*}"
    done

    if [ -e "$headfile" ]; then
        read -r head < "$headfile" || return
        case "$head" in
            ref:*) branch="${head##*/}" ;;
            "") branch="" ;;
            *) branch="${head:0:7}" ;;  #Detached head. You can change the format for this too.
        esac
    fi

    if [ -z "$branch" ]; then
        return 0
    fi

    if [ -z "$1" ]; then
        # Default format
        printf "(%s) " "$branch"
    else
        # Use passed format string
        printf "$1" "$branch"
    fi
}
```

2. Then add below section somewhere in your `~/.bashrc` file: 

```bash
export Grn='\[\e[1;32m\]' Blu='\[\e[1;34m\]'  Rst='\[\e[0m\]' # Color green, blue & reset
# ~/.fast-git-prompt.sh = https://gist.github.com/Ragnoroct/c4c3bf37913afb9469d8fc8cffea5b2f
if [[ -f ~/.fast-git-prompt.sh ]]; then
    source ~/.fast-git-prompt.sh
    export PS1="${Grn}[\h \W]${Rst} \$(__fastgit_ps1 '(${Blu}%s${Rst}) ')$ "
else
    export PS1="${Grn}[\h \W]${Rst}$ "
fi
```

The script above has been slightly reformated from [the original Github Gist](https://gist.github.com/Ragnoroct/c4c3bf37913afb9469d8fc8cffea5b2f).


## Host Static Site on Github Repo
Host a simple static *public* document web site based on [Markdown](https://www.markdownguide.org/cheat-sheet) on Github by doing the following:
1. Create a **public** Github repo with at least 2 files: An `index.md` and a `_config.yml`
2. Your repo name *must be named* `<username>.github.io`, but if you have your own domain to use for this, then the repo can be named anything
3. `index.md` is the home page, equivalent to a `README.md` or `index.html` file 
4. `_config.yml` tells [Github Pages](https://pages.github.com/) how to render your site, e.g. what theme to use, etc.
5. You can use [this very same site](https://que.one) as an example
6. Go to *Settings* section of your repo, then click on *Pages* under *Code and automation*
7. Under *Source* select your main or master branch
8. If using your own DNS domain, say `mydomain.com`, then set up the `www` CNAME and Anycast IP addresses as follows: 

```
www.mydomain.com    CNAME    git719.github.io.   # Where git719 is your Github username
@                   A        185.199.111.153     # These 4 are Github's Anycast IP addresses
@                   A        185.199.110.153
@                   A        185.199.109.153
@                   A        185.199.108.153
```

