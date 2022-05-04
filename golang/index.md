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
go mod init
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
vi .bashrc
export GOPATH=$HOME/.go
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin
```


## Install Go on Linux
To install Go on **Linux**:
```
curl -LO https://golang.org/dl/go1.17.2.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
tar -C /usr/local -xzf go1.17.2.linux-amd64.tar.gz
Add: export PATH=$PATH:/usr/local/go/bin to .bashrc
```

Or using this script, to automate future updates:
```
#!/bin/bash
# install-golang
Digest0=de874549d9a8d8d8062be05808509c09a88a248e77ec14eb77453530829ac02b
Ver=1.9.2
Archive=go${Ver}.linux-amd64.tar.gz
URL=https://storage.googleapis.com/golang/${Archive}
msg="Are you sure you want to DOWNLOAD and INSTALL GoLang archive '${Archive}'? Y/N "
read -p "$msg" -n 1 && [[ ! $REPLY =~ ^[Yy]$ ]] && printf "\nAborted.\n" && exit 1
echo Downloading $Archive ...
curl -LO $URL
Digest1=`shasum -a 256 go${Ver}*.tar.gz`
if [[ "$Digest0" -ne "$Digest1" ]]; then
    printf "Error. The digests are different!\nDigest0 = %s\nDigest1 = %s\n" "$Digest0" "$Digest1"
fi
echo Removing old version ...
sudo rm -rf /usr/local/go
echo Installing ...
tar -C /usr/local -xvzf $Archive
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
