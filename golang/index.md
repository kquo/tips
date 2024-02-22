# Go
Useful GoLang tips.


## References
- Useful examples = <https://gobyexample.com/>
- Static analysis = <https://github.com/analysis-tools-dev/static-analysis#go>

## Point to Local
While refactoring and troubleshooting code it is sometimes necessary to point to the local version of a package.

You can do this by modifying the `go.mod` file as follows:

```bash
require (
    github.com/git719/utl v1.1.11
)

replace github.com/git719/utl => /Users/myuser/mycode/utl
```

## Common Build Errors
When you get:
```bash
$ go build
go: go.mod file not found in current directory or any parent directory; see 'go help modules'
```
Do this
```
go mod init <package_name>   # For example, this would be 'zls' for github.com/git719/zls
go mod tidy
```


## Install Go
Use the [`install-golang.sh`](https://github.com/git719/tools/blob/main/bash/install-golang.sh) BASH script

1. `curl -LO https://raw.githubusercontent.com/git719/tools/main/bash/install-golang.sh`
2. Edit the script and change the line `GOVER="1.21.1"` to the version you want
3. `./install-golang.sh`
4. It tries to install at `$HOME/go`, so if you have a previous version you'll need to first back it up

This script can install Go on Windows within a GitBASH shell, or macos, or Linux Redhat (For RHEL `shasum` command is in package `perl-Digest-SHA``)


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
```go
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
```go
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
```makefile
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
