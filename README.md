# FrankenPHP Xdebug

This is a project to debug how to get xdebug running correctly with FrankenPHP

With Xdebug enabled **AND** liip imagine bundle installed and a filter applied when loading the initial page it gets stuck for a very long time and uses 100% cpu on a core per imagine filter being applied. 

Here that means it is stuck on 3 cores at 100%.

![htop.png](docs%2Fhtop.png)

To start the project run 

```shell
docker compose up
```

It will be available at [http://localhost:8888/](localhost:8888).

To start gdb for debugging : 

```shell
docker compose exec php sh
dpg -p 1
set logging enabled on
```

Then press `c` until the page is rendered (or atleast partially). This will create a `gdb.txt` file at the root of the project. 

## Xdebug versions

To change the Xdebug version modify `ENV XDEBUG_VERSION=3.2.1` in the [Dockerfile](./docker/php/Dockerfile).

## PHP versions

Using the alpine FrankenPHP image it can be changed from PHP8.3.3 to PHP 8.2.16 By changing 

```shell
FROM dunglas/frankenphp:1.1.0-alpine AS frankenphp_upstream
```

into 

```shell
FROM dunglas/frankenphp:1.1-php8.2.16-alpine AS frankenphp_upstream
```

The problem seems to only be for php 8.3.3


