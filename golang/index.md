# Go
Useful GoLang tips.


## Examples
Great examples <https://gobyexample.com/>


## Common Build Errors
When you get:
```
$ go build
go: go.mod file not found in current directory or any parent directory; see 'go help modules'
```
Do this
```
go mod init <prg_name|mod_name> # Simple name or github.com/git719/maz
go mod tidy
```
Or if you don't want to build as a module, this:
```
go env -w GO111MODULE=auto
go env # To view all Go variables
```


## Install Go on macOS
To install Go on **macOS** (see <http://sourabhbajaj.com/mac-setup/Go/README.html>):
```
brew update
brew install golang
vi ~/.bashrc
export GOPATH=~/go
export PATH=$GOPATH/bin:$PATH
```


## Install Go on Linux
To install Go on **Linux** manually: 

```
cd
curl -sLO https://go.dev/dl/go1.21.1.linux-amd64.tar.gz
tar xzf go1.21.1.linux-amd64.tar.gz
# Then add below two lines to your .bashrc file:
export GOPATH=~/go
export PATH=$GOPATH/bin:$PATH
```

Or semi-manually using below script: 

```
#!/bin/bash
# install-go.sh

Ver="1.21.1"
Filename="go${Ver}.linux-amd64.tar.gz"
cd
if [[ -d "go" ]]; then 
   printf "Director 'go' already exists. Aborting!\n"
   exit
fi

sudo dnf install -y perl-Digest-SHA jq curl

Files="$(curl -s https://go.dev/dl/?mode=json)"
curl -sLO https://go.dev/dl/${Filename}

DigestLocal=$(shasum -a 256 ${Filename} | awk '{print $1}')
DigestRemote=$(echo $Files | jq -r '.[] | .files[] | "\(.filename) \(.sha256)"' | grep "$Filename" | awk '{print $2}')
printf "\n%24s %s\n" "SHA DIGEST REMOTE" $DigestRemote
printf "\n%24s %s\n" "SHA DIGEST DOWNLOADED" $DigestLocal
if [[ "$DigestLocal" -ne "$DigestRemote" ]]; then
   printf "\nSHA digests do NOT match. Aborting!\n"
   exit
fi
print "\nSHA digests do match. Installing ...\n"
tar xzf $Filename
rm -vf $Filename
```

## Reduce Binary Executable Size
To reduce binary executable sizes:
1. Always compile with `-ldflags "-s -w"`
2. And use UPX:
```
brew install upx
upx -9 <binary>
```


## Useful Code Snippets

- Check if field exists in given struct
``` 
func FieldInStruct(Field string, Struct interface{}) bool {
    val := reflect.ValueOf(Struct)
    for i := 1; i < val.Type().NumField(); i++ {
        if val.Type().Field(i).Name == Field {
            return true
        }
    }
    return false
}
```

- Return list of JSON objects in local data file
```
func GetListFromLocalFile(storeFile string) interface{} {
    localFile := filepath.Join(progConfDir, storeFile)  // Note progConfDir is global
    JSONData, err := ioutil.ReadFile(localFile)
    if err != nil {
        panic(err)
    }

    switch storeFile {
    case InstanceDataFile:                     // Return list of instance records
        var list []InstanceType
        err = json.Unmarshal(JSONData, &list)
        if err != nil { panic(err) }
        return list
    case DNSDataFile:                          // Return list of DNS records
        var list []ResourceRecordSetType
        err = json.Unmarshal(JSONData, &list)
        if err != nil { panic(err) }
        return list
    case ELBDatafile:                          // Return list of ELB records
        var list []LoadBalancerDescriptionType
        err = json.Unmarshal(JSONData, &list)
        if err != nil { panic(err) }
        return list
    case ZoneDataFile:                         // Return list of zone records
        var list []HostedZoneType
        err = json.Unmarshal(JSONData, &list)
        if err != nil { panic(err) }
        return list
    case StackDataFile:                        // Return list of stack records
        var list []StackType
        err = json.Unmarshal(JSONData, &list)
        if err != nil { panic(err) }
        return list
    default:                                   // Return list of generic JSON records
        var list interface{}
        err = json.Unmarshal(JSONData, &list)
        if err != nil { panic(err) }
        return list
    }
}
```


## Common Makefile
Makefiles are usually not needed with Go, but if you must, this one for macOS and Linux will build target binaries for multiple OSes.
```
# Makefile
# Assumes GOPATH is already set up properly, e.g., $HOME/go

default:
  GOOS=darwin GOARCH=amd64 go build -ldflags "-s -w" -o build/macos/awsinfo
all:
  rm -rf build
  mkdir -p build/{macos,centos,windows}
  go get -u github.com/aws/aws-sdk-go/...
  go get -u github.com/vaughan0/go-ini
  GOOS=darwin GOARCH=amd64 go build -ldflags "-s -w" -o build/macos/awsinfo
  GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -o build/centos/awsinfo
  GOOS=windows GOARCH=amd64 go build -ldflags "-s -w" -o build/windows/awsinfo.exe

# Modify below target to where you keep your binaries
install:
  cp build/macos/awsinfo $(HOME)/data/bin
clean:
  rm -rf build
```


## Jenkins Golang Setup
This is really old, but may still be useful. 
```
Using the GoLang plugin
  Under "Source Code Management", select "Checkout to a sub-directory"
    e.g. src/github.com/lencap/awsinfo
    This will satisfy the vendoring setup
  Tick "Set up Go programming language tools" and select the proper version
  Add below to top of the Execute shell that's running Make
    export GOPATH=${WORKSPACE}
    export PATH="${PATH}:${GOPATH}/bin"
    cd ${GOPATH}/src/github.com/lencap/awsinfo
  Then run Make and after that, and so on

  ALSO, use "Archive the artifacts" to use the resulting binaries in other Jenkins jobs.
    Specify a "Files to archive" as specific as possible.
      e.g.: src/github.com/<org>/project-name/build/centos/BINARY

  On those other Jenkins project wanting to use the binaries, use "Copy artifacts from another project"
    Set "Flatten directories" to bring single binaries to the root of the WORKSPACE
```
