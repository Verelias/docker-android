# docker-android-alpine

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-green.svg)](https://www.gnu.org/licenses/gpl-3.0)

This is a fork of the docker-android project by faberNovel tailored for a smaller footprint and more efficient building.
docker-android-alpine provides general purpose docker images to run CI steps of Android project.
Docker allows you to provide a replicable environment, which does not change with the host machine or the CI service.
It should work out of the box on any CI/CD service providing docker support.
The image is providing standard tools to build and test Android application:
* Android SDK
* Java JDK 17
* Google Cloud CLI, to support [Firebase Test Lab](https://firebase.google.com/docs/test-lab)

## CI/CD service support
| CI/CD service | Tested |
| ------------- | ------ |
| [GitHub Actions](https://help.github.com/en/actions) | ✅ |
| [GitLab CI](https://docs.gitlab.com/ee/ci/docker/using_docker_images.html) | ✅ |
| [Circle CI](https://circleci.com/docs/2.0/executor-types/#using-docker) | 🚧 |
| [Travis CI](https://travis-ci.com/) | 🚧 |

## JDK support
Images support multiple JDK, using [Jenv](https://www.jenv.be/).
The default JDK is JDK 17.

## 📦 Container Registry
docker-android images are hosted on [DockerHub](https://hub.docker.com/r/verelias/docker-android-alpine).

## ✏️ Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

You can change image settings via its [Dockerfile](https://github.com/Verelias/docker-android).
You can build, test, and deploy image using [ci_cd.sh](https://github.com/Verelias/docker-android/blob/main/ci_cd.sh) script. You need to install docker first.
All scripts must be POSIX compliants.
```sh
usage: ./ci_cd.sh [--android-api 34] [--build-tools "34.0.0"] [--build] [--test]
  --android-api <androidVersion> Use specific Android version from `sdkmanager --list`
  --build-tools <version>        Use specific build tools version
  --android-ndk                  Install Android NDK
  --gcloud                       Install Google Cloud SDK
  --ndk-version <version>        Install a specific Android NDK version from `sdkmanager --list`
  --build                        Build image
  --test                         Test image
  --large-test                   Run large tests on the image (Firebase Test Lab for example)
  --deploy                       Deploy image
  --desc                         Generate a .md file in /desc/ouput folder describing the builded image, on host machine
```

## License
[GNU GPLv3](https://choosealicense.com/licenses/gpl-3.0/)
