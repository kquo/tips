# GIT
Version control tips. Mostly on `git` but may include others.


## Github Actions
- For great examples see <https://www.actionsbyexample.com/>
- For training info see <https://github.com/lencap/gh-abcs-actions>


## Common Commands
```
git checkout MASTER-BRANCH                   # Checkout the canonical source
git pull --rebase                            # Ensure most recent changes are in
git checkout -b MY_BRANCH                    # Create a local branch
git push --set-upstream origin MY_BRANCH     # Push it to origin, to work from it

# Make all your changes

git add .                                    # Add your changes
git commit -m "my changes"                   # Commit your changes

# Create a pull request (PR), have it peer-review, then merge via UI
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


## Remove Branches
```
git branch -d MY_BRANCH                      # Delete local MY_BRANCH
git push origin :MY_BRANCH                   # Delete remote MY_BRANCH
git remote prune origin --dry-run            # Confirm which branches have been removed from remote
git remote prune origin                      # Remove them from local
```


## Compare Branches
```
git diff branch_A branch_B                   # Compare two branches
```


## General
```
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
```


## Switch from master to main
```
git branch -m master main
git push -u origin main
# Now go to the SCM UI and change to main branch
git push origin --delete master
```


## Squash or Clump Commits
```
git rebase -i HEAD~<number-of-previous-commits>
  eg: git rebase -i HEAD~15
When vi comes up, change all leading 'pick' entries to 'squash', EXCEPT for the top one
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


## Pull in Submodules Updates
```
git submodule init
git submodule update
git submodule foreach 'git fetch origin; git checkout $(git rev-parse --abbrev-ref HEAD); git reset --hard origin/$(git rev-parse --abbrev-ref HEAD); git submodule update --recursive; git clean -dfx'
# For Jenkins jobs it's better to use the git plugin 'Multiple SCM' option
```


## Removing Large, Old Files From Repo History
See http://git-scm.com/book/en/Git-Internals-Maintenance-and-Data-Recovery
```
git gc                 -- Pack up old loose objects
git count-objects -v   -- Check size-pack, it's in KB
git verify-pack -v .git/objects/pack/pack-*.idx | sort -k 3 -n | tail -3    -- Find largest packed files
git rev-list --objects --all | grep "c7b03017"  -- Get actual file name (grep 1st few ltrs of target obj ID)
git log --pretty=oneline --branches -- file/work.tgz -- Show commits that modded file "file/work.tgz"
git filter-branch --index-filter 'git rm --cached --ignore-unmatch file/work.tgz' -- d0ff408^..
  -- Rewrite all commits downstream from d0ff408 (last commit) to fully remove the file
rm -rf .git/logs/ .git/refs/original -- To fully remove references to this file
git gc                 -- PAck up old loose objects again
git count-objects -v  -- See how much space we've saved
```


## Adding a Submodule to a Repo
```
git submodule add git://github.com/whosever/whatever.git foo/bar
```


## Merge Specific Files From Another Branch
```
git branch # View branches
* ci
  stag
  prod
vi somepath/file/code.src
git status
git add .
git commit -m "some change"
git push

git checkout stag
git pull --rebase
git checkout ci somepath/file/code.src
git status
git add .
git commit -m "some change"
git push

git checkout prod
git pull --rebase
git checkout ci somepath/file/code.src
git status
git add .
git commit -m "some change"
git push
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


## Remove a Submodule
```
Delete the relevant section from the .gitmodules file.
Stage the .gitmodules changes git add .gitmodules
Delete the relevant section from .git/config.
Run git rm --cached path_to_submodule (no trailing slash).
Run rm -rf .git/modules/path_to_submodule
Commit git commit -m "Removed submodule <name>"
Delete the now untracked submodule files
rm -rf path_to_submodule
```


## Tags
```
git tag                               # List tags
git tag -l "v1.8.5*"                  # Search tags
git tag -a v1.4 -m "my version 1.4"   # Create/annotate a tag
git tag -a v1.2 9fceb02               # Tag existing commit
git push origin v1.5                  # Share tag by pushing to origin
git push origin --tags                # Share all tags
git checkout -b v2.0.0 v2.0.0         # Checkout a tag (it actually creates a new branch)
git tag -d v2.0.0                     # Delete a tag locally ...
git push origin :refs/tags/v2.0.0     # ... and remotely
```


## Search For Specific Hash Across Branches
```
git branch --contains GITHASH
```


## Resolve Conflicts
```
git mergetool
```


## Common SVN Commands
```
svn co --username=USER --password=PWD https://svn-scm.domain.com/repo/mycode
svn add file_or_dir_namesvn delete file_or_dir_name
svn diff     # what's diff between your files and repos?
svn update   # update your copy with repo's latest changes
svn status   # list status of recently changed files (with search codes)
svn clenaup  # searches your working copy and runs any leftover to-do items, removing working copy locks, etc
svn resolve file_or_dir_name  # accept as final
svn ci -m "Saving recent changes" --username=USER --password=PWD https://svn-scm.domain.com/repo/mycode
```

See also:
* <http://svnbook.red-bean.com/en/1.4/svn-book.html>
* <http://svnbook.red-bean.com/en/1.4/svn-book.html#svn.tour.cycle>


## Store Credentials on macOS Keychain
```
git config --global credential.helper osxkeychain
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
To Show branch in BASH prompt, add the following to your `.bashrc` file:
```
gitbranch() {
    Branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    [[ -n "$Branch" ]] && echo "($Branch)" || echo ""
}
export PS1="\[\033[00;32m\]\u@\h:\W\[\033[00m\]\[\033[01;34m\]\$(gitbranch)\[\033[00m\]$ "
export PS1="\[$Grn\]\u@\h:\W\[$Rst\]\[$Blu\]\$(gitbranch)\[$Rst\]$ "
```


## Vault Pre-Commit Linter
Place below two scripts in `REPO/scripts/` directory with `755` perms:

Put a note in the repo's README to run the installation:
`$ scripts/install-pre-commit.sh`

All subsequent commits will run Vault linter on each policy file
```
#!/bin/bash
# pre-commit
BLUE2='\e[1;34m' ; RED2='\e[1;31m' ; NC='\e[0m'
printf "${BLUE2}pre-commit checks starting ...${NC}\n"
[[ -z "$(which vault)" ]] && printf "${RED2}Can't find 'vault' binary${NC}\n" && exit 1
# Run Vault linter on each policy file about to be committed
for PolicyFile in `git diff HEAD --name-only | grep "\.policy$"` ; do
    # If file doesn't exist then it is probably being deleted, and we don't care to lint
    if [[ -f "$PolicyFile" ]]; then
        vault policy fmt $PolicyFile
        [[ "$?" != "0" ]] && printf "${RED2}--> ${PolicyFile}${NC}\n" && exit 1
    fi
done
printf "${BLUE2}pre-commit checks successfully completed${NC}\n"
exit 0
```
and
```
#!/bin/bash
# install-pre-commit.sh
BLUE2='\e[1;34m' ; RED2='\e[1;31m' ; NC='\e[0m'
CMD="ln -sfv ../../scripts/pre-commit.sh .git/hooks/pre-commit"
$CMD
[[ "$?" != "0" ]] && printf "${RED2}Error setting up the '$CMD' symlink${NC}\n" && exit 1
printf "${BLUE2}Successfully set up pre-commit symlink${NC}\n"
exit 0
```


## Host Static Site on Github Repo
Host a simple static *public* document web site based on [Markdown](https://www.markdownguide.org/cheat-sheet) on Github by doing the following:
1. Create a **public** Github repo with at least 2 files: An `index.md` and a `_config.yml`
2. Your repo name *must be named* `<username>.github.io`, but if you have your own domain to use for this the repo can be named anything
3. `index.md` is the home page, equivalent to a `README.md` or `index.html` file 
4. `_config.yml` tells [Github Pages](https://pages.github.com/) how to render your site, e.g. what theme to use, etc.
5. You can use [this very same site](https://que.tips) as an example
6. Go to *Settings* section of your repo, then click on *Pages* under *Code and automation*
7. Under *Source* select your main or master branch
8. If using your own DNS domain, say `mydomain.com`, then set that up accordingly
9. Update your DNS domain records as follows:
```
www.mydomain.com    CNAME    lencap.github.io.
@                   A        185.199.111.153
@                   A        185.199.110.153
@                   A        185.199.109.153
@                   A        185.199.108.153
```
