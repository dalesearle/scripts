#!/bin/zsh

# https://pkg.go.dev/google.golang.org/grpc/cmd/protoc-gen-go-grpc
GOLANG_GRPC_PLUGIN_VERSION=1.3.0
# https://pkg.go.dev/google.golang.org/protobuf/cmd/protoc-gen-go
GOLANG_PROTOBUF_PLUGIN_VERSION=v1.31.0
# https://go.dev/dl/
GOLANG_VERSION=1.21.0
# https://github.com/grpc/grpc/releases
GRPC_VERSION=1.57.0
# https://github.com/protocolbuffers/protobuf/releases
PROTOC_VERSION=24.1

function createRepositories {
  [ ! -d "go" ] && mkdir go && echo "created tmp golang repository"
  [ ! -d "java" ] && mkdir java && echo "created tmp java repository"
  [ ! -d "python" ] && mkdir python && mkdir python/stubs && echo "created tmp python repository"
  [ ! -d "servers" ] && mkdir servers && echo "created servers directory"
  [ ! -d "servers/go" ] && mkdir servers/go && echo "created servers/go directory"
  [ ! -d "servers/java" ] && mkdir -p servers/java/src/main/java && echo "created servers/java directories"
  [ ! -d "servers/python" ] && mkdir servers/python && echo "created servers/python directory"
  [ ! -d "clients" ] && mkdir clients && echo "created clients directory"
  [ ! -d "clients/go" ] && mkdir clients/go && echo "created clients/go directory"
  [ ! -d "clients/java" ] && mkdir -p clients/java/src/main/java && echo "created clients/java directories"
  [ ! -d "clients/python" ] && mkdir clients/python && echo "created clients/python directory"
}

function compileGolangStubs {
  echo "compiling golang grpc stubs"
  # Compile golang code
  $PROTOC_COMPILER \
    --go_out=. \
    --go-grpc_out=. \
    --proto_path="$(pwd)"/proto \
    --proto_path="$PROTOC_INCLUDES" \
    "$(pwd)"/proto/*.proto
}

function compileJavaStubs {
  echo "compiling java grpc stubs"
  # Compile java code
  $PROTOC_COMPILER \
    --plugin=protoc-gen-grpc-java=$JAVA_GRPC_PLUGIN \
    --java_out=java \
    --grpc-java_out=java \
    --proto_path="$(pwd)"/proto \
    --proto_path="$PROTOC_INCLUDES" \
    "$(pwd)"/proto/*.proto
}

function compilePythonStubs {
  echo "compiling python grpc stubs"
  # Compile python code
  python3 -m grpc_tools.protoc \
    --pyi_out=python/stubs \
    --grpc_python_out=python/stubs \
    --proto_path="$(pwd)"/proto \
    --proto_path="$PROTOC_INCLUDES" \
    "$(pwd)"/proto/*.proto
}

function copyGoStubs {
  cp -R go/ servers/go
  [ $? = 0 ] && echo "copied golang stubs to server/go repo"
  cp -R go/ clients/go
  [ $? = 0 ] && echo "copied golang stubs to clients/go repo"
}

function copyJavaStubs {
  cp -R java/com servers/java/src/main/java
  [ $? = 0 ] && echo "copied java stubs to server/java repo"
  cp -R java/com clients/java/src/main/java
  [ $? = 0 ] && echo "copied java stubs to clients/java repo"
}

function copyPythonStubs {
  cp -R python/stubs servers/python
  [ $? = 0 ] && echo "copied pyton stubs to server/python repo"
  cp -R python/stubs clients/python
  [ $? = 0 ] && echo "copied stubs to clients/python repo"
}

function cleanup {
  rm -rf go
  rm -rf java
  rm -rf python
}

PROTOC_OSX_X86_64_URL="https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOC_VERSION/protoc-$PROTOC_VERSION-osx-x86_64.zip"
PROTOC_OSX_AARCH_64_URL="https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOC_VERSION/protoc-$PROTOC_VERSION-osx-aarch_64.zip"
PROTOC_REPOSITORY=$HOME"/protoc/"
PROTOC_COMPILER=$PROTOC_REPOSITORY$PROTOC_VERSION"/bin/protoc"
PROTOC_INCLUDES=$PROTOC_REPOSITORY$PROTOC_VERSION"/include/"
function installProtocCompiler {
  echo "checking protoc compiler installation"
  if [ ! -f $PROTOC_COMPILER ]; then
    echo "installing protoc compiler"
    [ ! -d $PROTOC_REPOSITORY$PROTOC_VERSION ] && mkdir -p $PROTOC_REPOSITORY$PROTOC_VERSION && echo "created protoc repository $PROTOC_REPOSITORY$PROTOC_VERSION"
    if [ "$(uname -m)" = "x86_64" ]; then
      curl $PROTOC_OSX_X86_64_URL -L -o protoc.zip
    elif [ "$(uname -m)" = "arm64" ]; then
      curl $PROTOC_OSX_AARCH_64_URL -L -o protoc.zip
    else
      echo "unsupported protoc architecture: $(uname -m)"
      exit 1
    fi
    unzip protoc.zip -d "$PROTOC_REPOSITORY$PROTOC_VERSION"
    rm protoc.zip
  else
    echo "protoc compiler installed $PROTOC_COMPILER"
  fi
}

JAVA_PLUGIN_OSX_X86_64_URL="https://repo1.maven.org/maven2/io/grpc/protoc-gen-grpc-java/$GRPC_VERSION/protoc-gen-grpc-java-$GRPC_VERSION-osx-x86_64.exe"
JAVA_PLUGIN_OSX_AARCH_64_URL="https://repo1.maven.org/maven2/io/grpc/protoc-gen-grpc-java/$GRPC_VERSION/protoc-gen-grpc-java-$GRPC_VERSION-osx-aarch_64.exe"
JAVA_PLUGIN_REPOSITORY=$PROTOC_REPOSITORY"plugins/java/"
JAVA_GRPC_PLUGIN_VERSION="protoc-gen-grpc-java-$GRPC_VERSION"
JAVA_GRPC_PLUGIN=$JAVA_PLUGIN_REPOSITORY$JAVA_GRPC_PLUGIN_VERSION
function installJavaPlugin {
  echo "checking java grpc plugin installation"
  [ ! -d "$JAVA_PLUGIN_REPOSITORY" ] && mkdir -p "$JAVA_PLUGIN_REPOSITORY" && echo "created java plugins repository $JAVA_PLUGIN_REPOSITORY"
  if [ ! -f "$JAVA_GRPC_PLUGIN" ]; then
    echo "installing java grpc plugin"
    if [ "$(uname -m)" = "x86_64" ]; then
      curl "$JAVA_PLUGIN_OSX_X86_64_URL" -L -o $JAVA_GRPC_PLUGIN_VERSION
    elif [ "$(uname -m)" = "arm64" ]; then
      curl "$JAVA_PLUGIN_OSX_AARCH_64_URL" -L -o $JAVA_GRPC_PLUGIN_VERSION
    else
      echo "unsupported java plugin architecture: $(uname -m)"
      exit 1
    fi
    chmod 555 $JAVA_GRPC_PLUGIN_VERSION
    mv $JAVA_GRPC_PLUGIN_VERSION "$JAVA_GRPC_PLUGIN"
  fi
  echo "java grpc plugin installed JAVA_GRPC_PLUGIN"
}

GOLANG_OSX_X86_64_URL="https://go.dev/dl/go$GOLANG_VERSION.darwin-amd64.tar.gz"
GOLANG_OSX_AARCH_64_URL="https://go.dev/dl/go$GOLANG_VERSION.darwin-arm64.tar.gz"
GOLANG_GOPATH=$HOME"/go"
GOLANG_GOROOT=$GOLANG_GOPATH"/release/"$GOLANG_VERSION
function installGolang {
  echo "checking golang installation"
  [ ! -d "$GOLANG_GOPATH" ] && mkdir -p "$GOLANG_GOPATH"/bin && mkdir "$GOLANG_GOPATH"/pkg && echo "created golang workspace $GOLANG_GOPATH"
  [ ! -d "$GOLANG_GOPATH/release" ] && mkdir "$GOLANG_GOPATH"/release
  if [ ! -d "$GOLANG_GOROOT" ]; then
    echo "installing golang version "$GOLANG_VERSION
    if [ "$(uname -m)" = "x86_64" ]; then
      curl $GOLANG_OSX_X86_64_URL -L -o golang.tar.gz
    elif [ "$(uname -m)" = "arm64" ]; then
      curl $GOLANG_OSX_AARCH_64_URL -L -o golang.tar.gz
    else
      echo "unsupported golang architecture: $(uname -m)"
      exit 1
    fi
    echo "extracting golang.tar.gz"
    tar -xf golang.tar.gz -C "$GOLANG_GOPATH"/release
    rm golang.tar.gz
    mv "$GOLANG_GOPATH"/release/go "$GOLANG_GOROOT"
    printf "Golang version $GOLANG_VERSION has been installed at %s \
      \n\e[1;31m**ATTENTION**\nThe following needs to be added/updated in your .zshrc or .bash_profile: \
      \t\nexport GOROOT=\$HOME/go/release/$GOLANG_VERSION \
      \nUpdate your path to include :\$GOROOT/bin:\$HOME/go/bin\e[0m \
      \npress enter AFTER editing is complete" "$GOLANG_GOROOT"
    read -r
    source ~/.zshrc
  fi
  echo "golang version $GOLANG_VERSION installed $GOLANG_GOROOT"
}

function installGolangProtobufPlugin {
  PBP="not installed"
  [ -f "$GOLANG_GOPATH/bin/protoc-gen-go" ] && PBP=$(protoc-gen-go --version)
  echo "checking golang protobuf generator, current version $PBP"
  if [ ! -f "$GOLANG_GOPATH/bin/protoc-gen-go" ]; then
    echo "installing golang protobuf generator"
    go install google.golang.org/protobuf/cmd/protoc-gen-go@$GOLANG_PROTOBUF_PLUGIN_VERSION
  elif [ "$PBP" != "protoc-gen-go $GOLANG_PROTOBUF_PLUGIN_VERSION" ]; then
    echo "updating golang protobuf generator to version $GOLANG_PROTOBUF_PLUGIN_VERSION"
    go install google.golang.org/protobuf/cmd/protoc-gen-go@$GOLANG_PROTOBUF_PLUGIN_VERSION
  fi
  echo "golang protobuf generator version $GOLANG_PROTOBUF_PLUGIN_VERSION installed $GOLANG_GOPATH/bin"
}

function installGolangGrpcPlugin {
  PBGP="not installed"
  [ -f "$GOLANG_GOPATH/bin/protoc-gen-go-grpc" ] && PBGP=$(protoc-gen-go-grpc --version)
  echo "checking golang grpc generator, current version $PBGP"
  if [ ! -f "$GOLANG_GOPATH/bin/protoc-gen-go-grpc" ]; then
    echo "installing golang grpc generator"
    # Take note, --version does not return a v1.x.x.x but go install wants the v.1.x.x so i had to add it
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@"v$GOLANG_GRPC_PLUGIN_VERSION"
  elif [ "$PBGP" != "protoc-gen-go-grpc $GOLANG_GRPC_PLUGIN_VERSION" ]; then
    echo "updating golang grpc generator to version $GOLANG_GRPC_PLUGIN_VERSION"
    # Take note, --version does not return a v1.x.x.x but go install wants the v.1.x.x so i had to add it
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@"v$GOLANG_GRPC_PLUGIN_VERSION"
  fi
  echo "golang grpc generator version $GOLANG_GRPC_PLUGIN_VERSION installed $GOLANG_GOPATH/bin"
}

function promptPythonInstall {
  echo "\e[1;31m**ATTENTION**\nYou need a python3 version greater than 3.4 to compile protobuf stubs," \
    "\n install at https://www.python.org/downloads/ \e[0m" \
    "\npress enter AFTER python3 has been installed"
  read -r
  source ~/.zshrc
}

function installPython {
  PYTHON_VERSION=$(python3 --version | cut -d" " -f2)
  if [ $? = 0 ]; then
    echo "current python version "$PYTHON_VERSION
    PYTHON_MAJOR_VERSION=$(echo $PYTHON_VERSION | cut -d"." -f1)
    PYTHON_MINOR_VERSION=$(echo $PYTHON_VERSION | cut -d"." -f2)
    if [ $PYTHON_MAJOR_VERSION = 3 ] && [ $PYTHON_MINOR_VERSION -ge 4 ]; then
      echo "python install is grpc compatible"
    else
      promptPythonInstall
    fi
  else
    promptPythonInstall
  fi
  pip3 install grpcio-tools==$GRPC_VERSION
}
# TODO: uninstall?
if [ ! -v "$1" ] && [ "$1" = "install" ]; then
  installProtocCompiler
  installJavaPlugin
  installGolang
  installGolangProtobufPlugin
  installGolangGrpcPlugin
  installPython
fi
createRepositories
compileGolangStubs
compileJavaStubs
compilePythonStubs
copyGoStubs
copyJavaStubs
copyPythonStubs
cleanup
