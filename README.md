# OWASP Dependency-Check (for Offline / Air-gap environment)

OWASP Dependency-Check workflows in an offline / air-gap environment

## Build

```sh
# Build image with latest database
docker build . -t dependency-check
# Skip database download (useful for downloading database to local filesystem)
docker build --build-arg SKIP_DOWNLOAD=1 . -t dependency-check
```

## Setup Initial Local Dependency-Check Database

```sh
# Create data directory (Linux)
DATA_DIRECTORY=$HOME/OWASP-Dependency-Check/data
mkdir -p $DATA_DIRECTORY
# Create data directory (Windows)
set DATA_DIRECTORY=%USERPROFILE%\OWASP-Dependency-Check\data
mkdir %DATA_DIRECTORY%

# Download database to data directory (for image without database)
docker run --rm -v %DATA_DIRECTORY%:/usr/share/dependency-check/data dependency-check --updateonly

# Copy database to data directory (for image with database)
docker run --rm -dit --entrypoint /bin/bash --name dc dependency-check
docker cp dc:/usr/share/dependency-check/data ./data
docker rm -f dc
```

## Update Local Dependency-Check Database (Online)

```sh
# Linux
DATA_DIRECTORY=$HOME/OWASP-Dependency-Check/data
docker run --rm \
    --volume %DATA_DIRECTORY%:/usr/share/dependency-check/data \
    dependency-check --updateonly

# Windows
set DATA_DIRECTORY=%USERPROFILE%\OWASP-Dependency-Check\data
docker run --rm ^
    --volume %DATA_DIRECTORY%:/usr/share/dependency-check/data ^
    dependency-check --updateonly
```

## Update Local Dependency-Check Database (Offline / Air-Gap)

### Mirror Resources

* [JS Repo](https://raw.githubusercontent.com/RetireJS/retire.js/master/repository/npmrepository.json)
* [NVD from NIST](https://github.com/stevespringett/nist-data-mirror/)

```sh
java -jar nist-data-mirror.jar <mirror-directory>
```

### Using Mirrored Resources to Update Local Dependency-Check Database

```sh
# Linux
DATA_DIRECTORY=$HOME/OWASP-Dependency-Check/data
docker run --rm \
  --volume %DATA_DIRECTORY%:/usr/share/dependency-check/data \
  dependency-check --updateonly \
  --cveUrlModified file:///usr/share/dc/nvd/nvdcve-1.1-modified.json.gz \
  --cveUrlBase file:///usr/share/dc/nvd/nvdcve-1.1-%d.json.gz \
  --retireJsUrl file:///usr/share/dc/jsrepository.json

# Windows
set DATA_DIRECTORY=%USERPROFILE%\OWASP-Dependency-Check\data
docker run --rm ^
  --volume %DATA_DIRECTORY%:/usr/share/dependency-check/data ^
  dependency-check --updateonly ^
  --cveUrlModified file:///d:/dc/nvd/nvdcve-1.1-modified.json.gz ^
  --cveUrlBase file:///d:/dc/nvd/nvdcve-1.1-%d.json.gz ^
  --retireJsUrl file:///d:/dc/jsrepository.json
```

## Reference

* [Home](https://owasp.org/www-project-dependency-check/)
* [GitHub](https://github.com/jeremylong/DependencyCheck)
* [Documentation](https://jeremylong.github.io/DependencyCheck/)
* [Command Line Arguments](https://jeremylong.github.io/DependencyCheck/dependency-check-cli/arguments.html)
