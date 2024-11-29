# Shell
Useful command-line shell tips.

## Postman REST API Caller
The simplest shell alias to call a REST API can be:

    $ alias pman='curl -sH "Authorization: Bearer $(token_utility) -H "Content-Type: application/json"
    $ pman -X GET "https://some-api.com/resource?param1=x&param2=y"

Such alias can be extended to a simple shell script, such as <https://github.com/git719/azm/blob/main/pman/README.md>

## Bash Script Safety
Using `set -euo pipefail` at the top of your shell scripts improves reliability, and error handling. It helps detect issues early and makes scripts more robust:

- `set -e`: Exit the script immediately if any command exits with a non-zero status, preventing further execution of potentially incorrect commands.
- `set -u`: Treat unset variables as an error and exit immediately. This avoids unexpected behavior due to typos or missing variables.
- `set -o pipefail`: Ensures that the script fails if any command in a pipeline fails, not just the last one. This is critical for catching errors in pipelines.
- **References:**
  - <https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425>
  - <http://redsymbol.net/articles/unofficial-bash-strict-mode/>


## Crontab
- General crontab format 

    # ┌───────────── Min (00 - 59)
    # │  ┌────────── Hour (00 - 23)
    # │  │  ┌─────── Day of month (1 - 31)
    # │  │  │  ┌──── Month (01 - 12)
    # │  │  │  │  ┌─ Day of week (0 - 7) (0 or 7 is Sunday; or use names)
    # *  *  *  *  *  Command_to_execute
    MAILTO=""        # Cron jobs are too chatty

- Linux Vixie crontab allows slashes. For example, to run `command` every 4 min starting at 00 

    00-59/4 * * * * command

- Periodic cleanup 

    10 0 * * * find /runtime/site/main/backups -type f -name "site-name*.bak" -mtime +45 -exec rm -rf {} \;

- List all crontabs in system 
    
    tail -n 1000 /var/spool/cron/*


## Unix Diff
Useful Unix `diff` tips.

- Diff DIR1 and DIR2 with exclusions 

    diff -r -x ".Spotlight*" -x ".DS_Store*" -x ".DocumentRevisions-V100*" -x ".fseventsd*" -x ".TemporaryItems*" DIR1 DIR2


## Bash Colorized Printing
- Display colorized source code with 'source-highlight' utility (check it's installed) 

    $HILITE -s bash --out-format=esc

## Remove Shell Colorized Output
If you have a text file filled with colorized escaped sequences, and want to remove it, use `sed` 

    sed 's/\x1B\[[0-9;]\{1,5\}[mGK]//g' colored_file.txt > cleaned_file.txt


## Bash Colors
There are two ways of doing colors with bash.

- __Terminal sequence__: Usually the safest way to colorize without interfering with other programs 

    BLACK="$(tput setaf 0)"  GRAY2="$(tput bold; tput setaf 0)"  RED="$(tput setaf 1)"    RED2="$(tput bold; tput setaf 1)"
    GREEN="$(tput setaf 2)"  GREEN2="$(tput bold; tput setaf 2)" YELLOW="$(tput setaf 3)" YELLOW2="$(tput bold; tput setaf 3)"
    BLUE="$(tput setaf 4)"   BLUE2="$(tput bold; tput setaf 4)"  PURPLE="$(tput setaf 5)" PURPLE2="$(tput bold; tput setaf 5)"
    CYAN="$(tput setaf 6)"   CYAN2="$(tput bold; tput setaf 6)"  GRAY="$(tput setaf 7)"   WHITE="$(tput bold; tput setaf 7)"
    NC="$(tput sgr0)"
    printf "${YELLOW2}Terminal/Bash colors${NC}\n"

- __Escape sequence__: Simplest method but sometimes can interfere with other programs 

    BLACK='\e[0;30m'  GRAY2='\e[1;30m'   RED='\e[0;31m'     RED2='\e[1;31m'
    GREEN='\e[0;32m'  GREEN2='\e[1;32m'  YELLOW='\e[0;33m'  YELLOW2='\e[1;33m'
    BLUE='\e[0;34m'   BLUE2='\e[1;34m'   PURPLE='\e[0;35m'  PURPLE2='\e[1;35m'
    CYAN='\e[0;36m'   CYAN2='\e[1;36m'   GRAY='\e[0;37m'    WHITE='\e[1;37m'
    NC='\e[0m'
    printf "${YELLOW2}Terminal/Bash colors${NC}\n"
    # WARNING: When working with PS1 prompt you MUST WRAP these with '\[' and '\]'!

- __24-bit true color sequences__ 

    Rst="\e[0m" ; SEQ=$(seq 0 32 255) ; for i in $SEQ ; do for j in $SEQ ; do for k in $SEQ ; do C="\e[38;2;${i};${j};${k}m" ; printf "${C} \\\\e[38;2;${i};${j};${k}m ${Rst}" ; done
    ; done ; done ; echo


## Bash Cursor Positioning
Bash terminal console cursor positioning:

    pcur()    { echo -ne "\033[${1};${2}H" ; }  # Position cursor
    mcurfwd() { echo -ne "\033[${1}C" ; }       # Move cursor forward n columns
    clrscr()  { echo -ne "\033[2J" ; }          # Clear screen
    scur()    { echo -ne "\033[s" ; }           # Save the cursor position
    rcur()    { echo -ne "\033[u" ; }           # Restore the cursor position
    drawrect() {
      l=12
      x=39
      for i in 41 42 43 44 45 46 48 ; do
        echo -e "\033[7;${i}m FLOSS at 40 $l \033[m"
        #mcurfwd 39
        mcurfwd $((x + 1))
        l=$(($l + 1))
      done
    }
    clrscr
    scur
    pcur 12 40
    drawrect
    rcur


## Bash 4.0> associative arrays

    declare -A array
    array[foo]=bar
    array[bar]=foo
    for i in "${!array[@]}"; do
      printf "key = %s  value = %s\n" "$i" "${array[$i]}"
    done


## Bash For Loops
- Regular way 

    List="one two three"
    for i in $List ; do
        echo "$i"
    done

- C-like way 

    Count=3
    for (( i=1 ; i<=$Count ; i++ )) ; do
        echo "$i"
    done


## Bash Parameter Substitution

    A="30.0.2.15,"         # Variable itself
    A=${A#?}               # 0.0.2.15,
    A=${A%?}               # 30.0.2.15
    A=${A:0:1}             # 3
    A=${A:(-1)}            # ,
    A=${A#*.}              # .0.2.15,
    A=${A##*.}             # 15,
    A=${A%.*}              # 30.0.2
    A=${A%%.*}             # 30

    A="   10.0.2.16,   "

## Date Format Text Adjustment
- Convert YEAR from '24-10-02' to '2024-10-02' 

    sed -E 's/(^|[^0-9])([0-9]{2})-([0-9]{2})-([0-9]{2})([^0-9]|$)/\120\2-\3-\4\5/g' medical.txt

- Convert MONTH from '2024-10-02' to '2024-oct-02' 

    sed -E 's/-01-/-jan-/g; s/-02-/-feb-/g; s/-03-/-mar-/g; s/-04-/-apr-/g; s/-05-/-may-/g; s/-06-/-jun-/g; s/-07-/-jul-/g; s/-08-/-aug-/g; s/-09-/-sep-/g; s/-10-/-oct-/g; s/-11-/-nov-/g; s/-12-/-dec-/g' your_file.txt > updated_file.txt

## Trim Spaces
- Remove all spaces 

    echo " test test test " | tr -d ' '       # "testtesttest"

- Trim leading spaces 

    A=" test test test "
    echo $A | sed 's/ *$//' # Or  
    A="${A#"${A%%[![:space:]]*}"}"

- Trim trailing 

    A=" test test test "
    echo $A | sed 's/^ *//'
    A="${A%"${A##*[![:space:]]}"}"


## Replace Entire Line In-place

    sed -i '/TEXT_TO_BE_REPLACED/c\This line is removed by the admin.' /tmp/foo


## Print Part of Text File
Print file, starting on line 8 / remove 1st 7 lines 

    tail -n +8 $FILE


## Line Loop
Parse file line-by-line without mangling them. 

    Command | while read Line ; do
      Name=`echo $Line | sed 's/["|{|}]//g' | awk '{print $1}'`
      Id=`echo $Line | sed 's/["|{|}]//g' | awk '{print $2}'`
      printf "%-25s%s\n" $Name $Id
    done


## Unix Find 
Useful Unix `find` tips.

- Files older than 6 months and bigger than 1GB 

    find /path -mtime +180 -size +1G

- Find files but exclude directory 

    find /etc -not -path /etc/puppet -type f

- Find and in-place update files with sed

    find . -type f -exec sed -i s;/www.mydomain.com;/blog.mydomain.com;g {} \;


## Date Time Commands

    # DATE format example - macOS
    date -u +%Y-%m-%dT%H:%M:%SZ     # Displays 2017-05-04T23:36:00Z  -u means UTC

    # macOS only
    date -uv-5M +%Y-%m-%dT%H:%M:%SZ # -v-5M means 5 minutes ago

    # GNU date equivalent
    date -uv +%Y-%m-%dT%H:%M:%SZ --date '+5min'

    # DATE to EPOC conversion -- GNU date ONLY!!!
    OLDDATE="Wed Mar 26 13:17:08 EDT 2014"
    OLDSECS=`date -d "$OLDDATE" +%s`

    # SECONDS COMPARISON
    # Capture Unix Epoch time for later comparison
    OLDTIME=`date +%s` LAP=1
    # Do something, blah, blah, etc ...
    # Do something else if it's been 2 min
    [[ "`expr $(date +%s) - $OLDTIME`" -ge 120 ]] && printf "\nNetworking issues.\n" && exit 1
    # Or this... wait 10 minutes, splitting every 120 seconds
    OLDTIME=`date +%s` LAP=1
    printf "==> "
    while [[ $SOME_CONDITION ]]; do
      printf "." ; sleep 1
      [[ "`expr $(date +%s) - $OLDTIME`" -ge 600 ]] && break
      ! (( LAP++ % 120 )) && printf "\n==> "
    done

    # DAYS UNTIL
    now=$(date +%s) ; nov3=$(date +%s --date "2020-11-03") ; dif=$(($nov3-$now)) ; echo $(($dif/(3600*24)))


## Other Commands
- Get LINUX DISTRO 

    OS=$(lsb_release -si)
    ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
    VER=$(lsb_release -sr)
    # CentOS version
    COSVER=`grep -o "[0-9]" /etc/redhat-release | head -1`

- Remove tabs, newlines 

    cat FILE | tr -d '\t'   # Or in octal '\011' 
    cat FILE | tr -d '\n'
    # Replace every tab, newline with a space
    cat FILE | tr '\011' ' '
    cat FILE | tr '\n' ' '

- Replace any line ending with a 'Z' with a newline (ie, joins it to next line with a space) 

    sed ':a;N;$!ba;s/Z\n/ /g' FILE                     # On most unices
    sed -e ':a' -e 'N' -e '$!ba' -e 's/Z\n/ /g' FILE   # On OS X
    # Explanation:
    # sed always strips off the newline before the line is placed into the pattern space! So doing
    # sed 's/ Z\n/ /g' would never work. Intead, above expressions do the following:
    # 1. ':a' create label 'a'
    # 2. 'N' append the next line to the pattern space
    # 3. '$!' if not the last line, 'ba' branch (go to) label 'a'
    # 4. 's/ Z\n/ /g' do the substitution
    # sed loops through step 1 to 3 until it reaches the last line, putting all lines in the 
    # pattern space where it then substitutes all \n characters

- Join every other, every 3, or every 4 lines with a space 

    sed 'N;s/\n/ /g' FILE  # or paste -s -d' \n'
    sed 'N;N;s/\n/ /g' FILE
    sed 'N;N;N;s/\n/ /g' FILE

- Surround each empty-line-delimited paragraph with `_BEGIN_` and `__END__` 

    sed '/./{H;$!d} ; x ; s/^/\n_BEGIN_/ ; s/$/\n__END__/' input.txt


- Substitute between matches 

    sed '/MATCH1/,/MATCH2/ s/THIS/THAT/g' input.txt


## Print Specific Columns
- Print specific columns 

    cat TEXT.file | awk '{ $1=""; $2=""; print}'

also 

    cat TEXT.file | cut -d ' ' -f2-


- Print specific or remaining fields using `awk` 

    # Print the last field
    awk '{printf "%s\n", $(NF)}' multi-field-file.txt

    # Print first 2 fields, then all remaining fields
    awk '{printf "%-30s  %-6s %s\n", $1, $2, substr($0, index($0, $3))}' multi-field-file.txt

    # Print specific fields
    awk '{printf "%-50s  %-20s  %-12s  %-6s\n", $1, $(NF-12), $NF, $(NF-4)}' multi-field-file.txt


## Tally Similar Lines
Using `list.txt` as a sample text file to work with: 

    cat list.txt
    01
    01
    01
    02
    04
    05
    05

Do the tally based on the first and only column: 

    awk '{h[$1]++}END{for(i in h){printf "%2s %s\n", h[i],i | "sort -rn"}}' list.txt
    3 01
    2 05
    1 04
    1 02

Notice that you can change `h[$1]` to `h[$2]` if you want to process the 2nd column instead.


## Run Commands Over SSH
To run arbitrarily complex command over SSH you sometimes have to *pack* the command as a variable 

    printf -v CMD "%q" "sudo -i"
    ssh -t "$1" "exec bash -c $CMD"


## Sort List of String
Sort of a delimited list of string items with `tr` 

    List="gif|jpg|jpeg|bmp|png|tiff|tif|ico|img|tga|wmf|txt|js|css|svg|swf|mp3|mp4"
    echo $List | tr -s "|" "\n" | sort -u | tr -s "\n" "|"


## Other Commands

    # REVERSE COLUMN
    awk '{for(i=NF;i>=2;i--) {printf $i FS} {printf $1"\n"}}' text.file

    # Replace every occurrence of "\n" with an actual newline
    awk '{gsub(/\\n/,"\n")}1' FILE

    # Grep print only matches
    echo "something 1 2 3 line" | grep -o "[0-9]"

    # Print how long process has been running, in seconds
    PidNum=5057
    ps -p $PidNum -o etimes=

    # Print PID of a specific process string
    ps -o pid= -C collectd

    # Get PID of current/last command
    echo $$ 
    last-command.sh
    echo $!

    # Kill a process and ALL its decendents
    pkill -TERM -P $PidNum

    # Get host IP address Linux and OSX aliases
    /sbin/ip addr show | /bin/sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}'
    alias myip='ifconfig | sed -En '\''s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'\'''
    alias myipext='dig +short myip.opendns.com @resolver1.opendns.com'


## Commatized Number
    # Function
    Commatize () {
    echo $1 | sed -e :a -e 's/\(.*[0-9]\)\([0-9]\{3\}\)/\1,\2/;ta'
    }

    # Example
    Number=5375830958772676723
    NumberComma=$(Commatize $Number)
    echo $Number
    echo $NumberComma

    ...

    # Output
    5375830958772676723
    5,375,830,958,772,676,723


## Tally Integers In Columns
Two different ways to tally integers in a specific column 

    CNT=0; for S in `awk '{ print $7}' file.txt` ; do ((CNT = CNT + S)) ; done ; echo $CNT

    perl -lne '$s += $1 if / (\d+\.\d{0,2}) B$/; END{print $s}' file.txt


## Capitalize Word In File
Capitalize all words in a given texts file 

    sed -e "s/\b\(.\)/\u\1/g" file.txt


## Insert Variable In Lines
Insert specific variable `A` in all qualifying lines of sample text file `/etc/puppet/puppet.conf` 

    A=myhost.mydomain.com
    sed -i "s/^[^#]*certname *= *.*$/    certname = $A/g" /etc/puppet/puppet.conf


## Trim DNS List To Apex Domains Only
Given list of DNS names in `1.txt`, output only the their DNS apex domains into file `2.txt` 

    for n in `cat 1.txt` ; do
    new=`echo $n | rev | awk -F'.' '{print $1 "." $2}' | rev`
    echo $new >> 2.txt
    done


## JSON With Python
    msgBody=$(echo "$msg" | python -c 'import sys, json; print json.load(sys.stdin)["Messages"][0]["Body"]')


## Shell History
- Best method for clearing shell history 

    history -d $((HISTCMD-1)) && history -c && rm -rf $HISTFILE

- To always clear bash history on logout. Save `~/.bash_logout` with single oneliner of `history -c`.


## Sample BASHRC
Sample `.bashrc` file 

    export Grn='\e[1;32m' # Green
    export Rst='\e[0m'    # Text Reset
    export PATH=/usr/local/bin:/usr/local/sbin:$PATH:~/Library/Python/2.7/bin
    export PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
    export HISTCONTROL=ignoreboth
    export HISTIGNORE='ls:cd:ll:h'
    export EDITOR=vi
    export GOPATH=$HOME/go  # GoLang
    export PATH=$PATH:$GOPATH/bin:$GOROOT/bin
    export PS1="\[$Grn\]\u@\h:\W\[$Rst\]$ "
    alias ll='ls -ltr'
    alias date='date "+%a %Y-%m-%d %H:%M %Z"'
    alias vi='vim'
    alias h='history'
    alias myip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"


## One-Liners

    # Exclude list of patterns in a file with grep
    fgrep = grep -F
    egrep = grep -E
    grep -Fvf file-with-list-of-patterns-to-exclude.txt file-to-grep.txt

    # Change/touch file date time
    touch -t [[CC]YY]MMDDhhmm[.SS]

    # Find all set UID files
    find DIRTREE -xdev \( -per -4000 \) -type f -print0 | xargs -0 -ls -l

    # Sed find-n-replace on a set of files
    find DIRTREE ! -name "*.jpg$" ! -type d -exec sed -i "s;/stage-blog.tektrove.com;/blog.tektrove.com;g" {} \;

    # Find and clean log files older than x-number of days
    find DIRTREE -type f -name "*.log$" -mtime +30 -exec rm -rf "{}" \;
    # GNU Only
    find DIRTREE -type f -name "*.log$" -mtime +30 -delete

    # Recursively change perms on dir and files
    find DIRTREE -type d -exec chmod o+r,o+x {} +
    find DIRTREE -type f -exec chmod o+r {} +


## Graceful Trap Signal Exit
Useful exit function to clean up during a runtime trap signal event 

    trap "{ sh /root/.bash_logout ; }" EXIT
    trap "{ stop_node ; stop_nginx ; exit 0 ; }" EXIT SIGHUP SIGINT SIGQUIT SIGILL SIGSTOP SIGTERM
    exit_func() {
        # Clean up code here
    }
    trap exit_func EXIT SIGHUP SIGINT SIGQUIT SIGILL SIGSTOP SIGTERM


## Random

    echo $((1 + RANDOM % 10))        # A random number between 1 and 10
    echo $((32 + RANDOM % 95))       # a random ASCII char decimal value


## ASCII
    awk 'BEGIN{for(i=32;i<=127;i++)printf "%c",i}';echo   # Print all printable ASCII chars
    printf $(printf '\%o' {32..127})                      # Print all printable ASCII chars - BASH only
    printf $(printf '\%o' 65)                             # Print capital 'A' using decimal value '65'
    printf $(printf '\%o' $((32 + RANDOM % 95)))          # Print a random ASCII char
    printf -v A $(printf '\%o' $((32 + RANDOM % 95)))     # Assign variable A a random ASCII char


## Sine Wave Function
Command line sine wave function to play with 
    sinewave() {
    Width=$(tput cols)                                     # Get width of screen
    Middle=$((Width/2))
    Count=1
    while true ; do                                        # Infinity loop - CNTRL-C to exit
        Shift=$(echo "s($Count * 0.02) * $Middle" | bc -l)   # bc's sine function
        printf -v Shift %.0f "$Shift"                        # Convert float to integer
        ((Indent=Middle+Shift))
        printf -v CH $(printf '\%o' $((33 + RANDOM % 94)))   # Select a random ASCII char
        printf "%*s\n" $Indent "$CH"                         # Print it in sine wave indentation
        ((Count++))
    done
    }

    # Define the function as a one-liner, then run it:
    sinewave() { Width=$(tput cols) ; Middle=$((Width/2)) ; Count=1 ; while true ; do  Shift=$(echo "s($Count * 0.02) * $Middle" | bc -l) ; printf -v Shift %.0f "$Shift" ; ((Indent=Middle+Shift)) ; printf -v CH $(printf '\%o' $((33 + RANDOM % 94))) ; printf "%*s\n" $Indent "$CH" ; ((Count++)) ; done ; }

    sinewave


## wget vs curl

    wget -d --header="Host: www.wired.com" -O - http://URL > wget.log 2>&1
    curl -s -X POST -H "Host: www.wired.com" http://URL > curl.log 2>&1


## Gunzip URL
Use `curl` to `gunzip` the returned content from a URL. Doing this makes the request more predictable and compatible across different servers 

    curl -H "Accept-Encoding: gzip deflate" http://URL


## Test International Redirect
Use `X-Forwarded-For` header to test international HTTP redirects with `curl`. This may no longer 

    # Italian IP address
    curl -H "X-Forwarded-For: 79.13.226.127" http://www.mysite.com

    # French IP address
    curl -H "X-Forwarded-For: 5.42.160.1" http://www.mysite.com


## Split String Into Lines
Split given string into separate lines for each single character 

    echo "j2gDCeD s832h adsf" | fold -w1

Note that you can specify a different *width*, such as `-w2` to split by every 2 characters, and so on.
