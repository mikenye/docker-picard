# mikenye/picard

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/mikenye/docker-picard/Deploy%20to%20Docker%20Hub)](https://github.com/mikenye/docker-picard/actions?query=workflow%3A%22Deploy+to+Docker+Hub%22)
[![Docker Pulls](https://img.shields.io/docker/pulls/mikenye/picard.svg)](https://hub.docker.com/r/mikenye/picard)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/mikenye/picard/latest)](https://hub.docker.com/r/mikenye/picard)
[![Discord](https://img.shields.io/discord/734090820684349521)](https://discord.gg/sTf9uYF)

Docker container for MusicBrainz Picard

The GUI of the application is accessed through a modern web browser (no installation or configuration needed on client side) or via any VNC client.

---

[![Picard logo](https://picard.musicbrainz.org/static/img/picard-icon-large.svg)](https://picard.musicbrainz.org)[![MusicBrainz Picard](https://dummyimage.com/400x150/ffffff/575757&text=MusicBrainz%20Picard)](https://picard.musicbrainz.org)

Picard is a cross-platform music tagger written in Python.

---

This container is based on the absolutely fantastic [jlesage/baseimage-gui](https://hub.docker.com/r/jlesage/baseimage-gui). All the hard work has been done by them, and I shamelessly copied their README.md too. I've cut the README.md down quite a bit, for advanced usage I suggest you check out the [README](https://github.com/jlesage/docker-handbrake/blob/master/README.md) from [jlesage/baseimage-gui](https://hub.docker.com/r/jlesage/baseimage-gui).

---

## Quick Start

**NOTE**: The Docker command provided in this quick start is given as an example
and parameters should be adjusted to your need.

Launch the Picard docker container with the following command:

```shell
docker run -d \
    --name=picard \
    -p 5800:5800 \
    -v /path/to/config:/config:rw \
    -v /path/to/music:/storage:rw \
    mikenye/picard
```

Where:

* `/path/to/config`: This is where the application stores its configuration, log and any files needing persistency.
* `/path/to/music`: This location contains music files for Picard to operate on.

Browse to `http://your-host-ip:5800` to access the Picard GUI. Your music will be located under `/storage`.

## Usage

```shell
docker run [-d] \
    --name=picard \
    [-e <VARIABLE_NAME>=<VALUE>]... \
    [-v <HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]]... \
    [-p <HOST_PORT>:<CONTAINER_PORT>]... \
    mikenye/picard
```

| Parameter | Description |
|-----------|-------------|
| -d        | Run the container in background.  If not set, the container runs in foreground. |
| -e        | Pass an environment variable to the container.  See the [Environment Variables](#environment-variables) section for more details. |
| -v        | Set a volume mapping (allows to share a folder/file between the host and the container).  See the [Data Volumes](#data-volumes) section for more details. |
| -p        | Set a network port mapping (exposes an internal container port to the host).  See the [Ports](#ports) section for more details. |

### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable       | Description                                  | Default |
|----------------|----------------------------------------------|---------|
|`USER_ID`| ID of the user the application runs as.  See [User/Group IDs](#usergroup-ids) to better understand when this should be set. | `1000` |
|`GROUP_ID`| ID of the group the application runs as.  See [User/Group IDs](#usergroup-ids) to better understand when this should be set. | `1000` |
|`SUP_GROUP_IDS`| Comma-separated list of supplementary group IDs of the application. | (unset) |
|`UMASK`| Mask that controls how file permissions are set for newly created files. The value of the mask is in octal notation.  By default, this variable is not set and the default umask of `022` is used, meaning that newly created files are readable by everyone, but only writable by the owner. See the following online umask calculator: <http://wintelguy.com/umask-calc.pl> | (unset) |
|`TZ`| [TimeZone] of the container.  Timezone can also be set by mapping `/etc/localtime` between the host and the container. | `Etc/UTC` |
|`KEEP_APP_RUNNING`| When set to `1`, the application will be automatically restarted if it crashes or if user quits it. | `0` |
|`APP_NICENESS`| Priority at which the application should run.  A niceness value of -20 is the highest priority and 19 is the lowest priority.  By default, niceness is not set, meaning that the default niceness of 0 is used.  **NOTE**: A negative niceness (priority increase) requires additional permissions.  In this case, the container should be run with the docker option `--cap-add=SYS_NICE`. | (unset) |
|`CLEAN_TMP_DIR`| When set to `1`, all files in the `/tmp` directory are delete during the container startup. | `1` |
|`DISPLAY_WIDTH`| Width (in pixels) of the application's window. | `1280` |
|`DISPLAY_HEIGHT`| Height (in pixels) of the application's window. | `768` |
|`SECURE_CONNECTION`| When set to `1`, an encrypted connection is used to access the application's GUI (either via web browser or VNC client).  See the [Security](#security) section for more details. | `0` |
|`VNC_PASSWORD`| Password needed to connect to the application's GUI.  See the [VNC Password](#vnc-password) section for more details. | (unset) |
|`X11VNC_EXTRA_OPTS`| Extra options to pass to the x11vnc server running in the Docker container.  **WARNING**: For advanced users. Do not use unless you know what you are doing. | (unset) |
|`ENABLE_CJK_FONT`| When set to `1`, open source computer font `WenQuanYi Zen Hei` is installed.  This font contains a large range of Chinese/Japanese/Korean characters. | `0` |

### Data Volumes

The following table describes data volumes used by the container.  The mappings
are set via the `-v` parameter.  Each mapping is specified with the following
format: `<HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]`.

| Container path  | Permissions | Description |
|-----------------|-------------|-------------|
|`/config`| rw | This is where the application stores its configuration, log and any files needing persistency. |
|`/storage`| ro/rw | This location contains files from your host that need to be accessible by the application. Should be 'rw' if you want Picard to re-tag/re-name your files.|

### Ports

Here is the list of ports used by the container.  They can be mapped to the host
via the `-p` parameter (one per port mapping).  Each mapping is defined in the
following format: `<HOST_PORT>:<CONTAINER_PORT>`.  The port number inside the
container cannot be changed, but you are free to use any port on the host side.

| Port | Mapping to host | Description |
|------|-----------------|-------------|
| 5800 | Mandatory | Port used to access the application's GUI via the web interface. |
| 5900 | Optional | Port used to access the application's GUI via the VNC protocol.  Optional if no VNC client is used. |
| 8000 | Optional | Port used to access Picard's "browser integration" feature. Must be enabled in Picard's options (advanced > network, check "browser integration" and uncheck "listen only on localhost). |

### Changing Parameters of a Running Container

As seen, environment variables, volume mappings and port mappings are specified
while creating the container.

The following steps describe the method used to add, remove or update
parameter(s) of an existing container.  The generic idea is to destroy and
re-create the container:

1. Stop the container (if it is running):

```shell
docker stop picard
```

2. Remove the container:

```shell
docker rm picard
```

3. Create/start the container using the `docker run` command, by adjusting
     parameters as needed.

**NOTE**: Since all application's data is saved under the `/config` container
folder, destroying and re-creating a container is not a problem: nothing is lost
and the application comes back with the same state (as long as the mapping of
the `/config` folder remains the same).

## Docker Compose File

Here is an example of a `docker-compose.yml` file that can be used with
[Docker Compose](https://docs.docker.com/compose/overview/).

Make sure to adjust according to your needs.  Note that only mandatory network
ports are part of the example.

```yaml
version: '3'
services:
  picard:
    build: .
    ports:
      - "5800:5800"
    volumes:
      - "/path/to/config:/config:rw"
      - "/path/to/music:/storage:rw"
```

## Docker Image Update

If the system on which the container runs doesn't provide a way to easily update
the Docker image, the following steps can be followed:

1. Fetch the latest image:

```shell
docker pull mikenye/picard
```

2. Stop the container:

```shell
docker stop picard
```

3. Remove the container:

```shell
docker rm picard
```

4. Start the container using the `docker run` command.

## User/Group IDs

When using data volumes (`-v` flags), permissions issues can occur between the
host and the container.  For example, the user within the container may not
exists on the host.  This could prevent the host from properly accessing files
and folders on the shared volume.

To avoid any problem, you can specify the user the application should run as.

This is done by passing the user ID and group ID to the container via the
`USER_ID` and `GROUP_ID` environment variables.

To find the right IDs to use, issue the following command on the host, with the
user owning the data volume on the host:

```shell
id <username>
```

Which gives an output like this one:

```text
uid=1000(myuser) gid=1000(myuser) groups=1000(myuser),4(adm),24(cdrom),27(sudo),46(plugdev),113(lpadmin)
```

The value of `uid` (user ID) and `gid` (group ID) are the ones that you should
be given the container.

## Accessing the GUI

Assuming that container's ports are mapped to the same host's ports, the
graphical interface of the application can be accessed via:

* A web browser:

```text
http://<HOST IP ADDR>:5800
```

* Any VNC client:

```text
<HOST IP ADDR>:5900
```

## Security

By default, access to the application's GUI is done over an unencrypted
connection (HTTP or VNC).

Secure connection can be enabled via the `SECURE_CONNECTION` environment
variable.  See the [Environment Variables](#environment-variables) section for
more details on how to set an environment variable.

When enabled, application's GUI is performed over an HTTPs connection when
accessed with a browser.  All HTTP accesses are automatically redirected to
HTTPs.

When using a VNC client, the VNC connection is performed over SSL.  Note that
few VNC clients support this method.  [SSVNC] is one of them.

[SSVNC]: http://www.karlrunge.com/x11vnc/ssvnc.html

### Certificates

Here are the certificate files needed by the container.  By default, when they
are missing, self-signed certificates are generated and used.  All files have
PEM encoded, x509 certificates.

| Container Path                  | Purpose                    | Content |
|---------------------------------|----------------------------|---------|
|`/config/certs/vnc-server.pem`   |VNC connection encryption.  |VNC server's private key and certificate, bundled with any root and intermediate certificates.|
|`/config/certs/web-privkey.pem`  |HTTPs connection encryption.|Web server's private key.|
|`/config/certs/web-fullchain.pem`|HTTPs connection encryption.|Web server's certificate, bundled with any root and intermediate certificates.|

**NOTE**: To prevent any certificate validity warnings/errors from the browser
or VNC client, make sure to supply your own valid certificates.

**NOTE**: Certificate files are monitored and relevant daemons are automatically
restarted when changes are detected.

### VNC Password

To restrict access to your application, a password can be specified.  This can
be done via two methods:

* By using the `VNC_PASSWORD` environment variable.
* By creating a `.vncpass_clear` file at the root of the `/config` volume.
  This file should contains the password in clear-text.  During the container
  startup, content of the file is obfuscated and moved to `.vncpass`.

The level of security provided by the VNC password depends on two things:

* The type of communication channel (encrypted/unencrypted).
* How secure access to the host is.

When using a VNC password, it is highly desirable to enable the secure
connection to prevent sending the password in clear over an unencrypted channel.

**ATTENTION**: Password is limited to 8 characters.  This limitation comes from
the Remote Framebuffer Protocol [RFC](https://tools.ietf.org/html/rfc6143) (see
section [7.2.2](https://tools.ietf.org/html/rfc6143#section-7.2.2)).  Any
characters beyhond the limit are ignored.

## Shell Access

To get shell access to a the running container, execute the following command:

```shell
docker exec -ti picard bash
```

## Optional: Access to Optical Drive(s)

Picard can lookup CDs from an optical drive.

By default, a Docker container doesn't have access to host's devices.  However,
access to one or more device can be granted with the `--device DEV` parameter.

Optical drives usually have `/dev/srX` as device.  For example, the first drive
is `/dev/sr0`, the second `/dev/sr1`, and so on.  To allow Picard to access
the first drive, this parameter is needed:

```shell
--device /dev/sr0
```

To easily find devices of optical drives, start the container and look at its
log for messages similar to these ones:

```text
...
[cont-init.d] 95-check-optical-drive.sh: executing...
[cont-init.d] 95-check-optical-drive.sh: looking for usable optical drives...
[cont-init.d] 95-check-optical-drive.sh: found optical drive /dev/sr0, but it is not usable because is not exposed to the container.
[cont-init.d] 95-check-optical-drive.sh: no usable optical drive found.
[cont-init.d] 95-check-optical-drive.sh: exited 0.
...
```

## Getting Help

Having troubles with the container or have questions?  Please [create a new issue](https://github.com/mikenye/docker-picard/issues).

I also have a [Discord channel](https://discord.gg/zpxkMrY), feel free to [join](https://discord.gg/zpxkMrY) and converse.
