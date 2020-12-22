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

## Option 1: Update Local Dependency-Check Database (Online)

```sh
# Linux
DATA_DIRECTORY=$HOME/OWASP-Dependency-Check/data
docker run --rm \
    --volume $DATA_DIRECTORY:/usr/share/dependency-check/data \
    dependency-check --updateonly

# Windows
set DATA_DIRECTORY=%USERPROFILE%\OWASP-Dependency-Check\data
docker run --rm ^
    --volume %DATA_DIRECTORY%:/usr/share/dependency-check/data ^
    dependency-check --updateonly
```

## Option 2: Update Local Dependency-Check Database (Offline / Air-Gap)

To update the database, the following resources needs to be mirrored in air-gap environment.

### Mirror Resources

* [JS Repo](https://raw.githubusercontent.com/Retirejs/retire.js/master/repository/jsrepository.json)

   ```sh
   curl -LO https://raw.githubusercontent.com/Retirejs/retire.js/master/repository/jsrepository.json
   ```

* [NVD from NIST](https://github.com/stevespringett/nist-data-mirror/)

   ```sh
   # Download latest version of `nist-data-mirror.jar`
   curl -LO `curl -s -L https://api.github.com/repos/stevespringett/nist-data-mirror/releases/latest | jq -r '.assets[2].browser_download_url'`

   # Download *.json.gz and *.meta to nvd directory
   java -jar nist-data-mirror.jar ./nvd
   ```

### Using Mirrored Resources to Update Local Dependency-Check Database

```sh
# Linux
DATA_DIRECTORY=$HOME/OWASP-Dependency-Check/data
MIRROR_DIRECTORY=$HOME/mirror
docker run --rm \
  --volume %DATA_DIRECTORY%:/usr/share/dependency-check/data \
  --volume %MIRROR_DIRECTORY%:/usr/share/mirror \
  dependency-check --updateonly \
  --cveUrlModified file:///usr/share/dc/nvd/nvdcve-1.1-modified.json.gz \
  --cveUrlBase file:///usr/share/dc/nvd/nvdcve-1.1-%d.json.gz \
  --retireJsUrl file:///usr/share/dc/jsrepository.json

# Windows
set DATA_DIRECTORY=%USERPROFILE%\OWASP-Dependency-Check\data
set MIRROR_DIRECTORY=%USERPROFILE%/mirror

docker run --rm ^
  --volume %DATA_DIRECTORY%:/usr/share/dependency-check/data ^
  --volume %MIRROR_DIRECTORY%:/usr/share/mirror ^
  dependency-check --updateonly ^
  --cveUrlModified file:///usr/share/mirror/nvd/nvdcve-1.1-modified.json.gz ^
  --cveUrlBase file:///usr/share/mirror/nvd/nvdcve-1.1-%d.json.gz ^
  --retireJsUrl file:///usr/share/mirror/jsrepository.json
```

## Reference

* [Home](https://owasp.org/www-project-dependency-check/)
* [GitHub](https://github.com/jeremylong/DependencyCheck)
* [Documentation](https://jeremylong.github.io/DependencyCheck/)
* [Command Line Arguments](https://jeremylong.github.io/DependencyCheck/dependency-check-cli/arguments.html)
