MulVAL
======

MulVAL: A logic-based, data-driven enterprise network security analyzer

Build Status: [![Build Status](https://travis-ci.org/fiware-cybercaptor/mulval.svg?branch=master)](https://travis-ci.org/fiware-cybercaptor/mulval)

Originally developed at Kansas State University, version updated for FIWARE CyberCAPTOR.

## Build

### Prerequisite

MulVAL needs Java and a C++ compiler to be built.

This can be installed for example on Debian-like distributions using:

```
apt-get install g++ openjdk-7-jdk
```

MulVAL also needs bison and flex dependencies.

This can be installed for example on Debian-like distributions using:

```
apt-get install bison flex
```

### Build

Before building MulVAL, the `MULVALROOT` environment variable has to be set to the folder on which MulVAL will be built.

```
export MULVALROOT=/path/to/mulval
```

Then, MulVAL can be build with

```
make
```


## Documentation

MulVAL original documentation (installation and user guide) can be found in [doc/README](doc/README)