# mORMot External Libraries

## Folder Content

This folder gives access to the *External Libraries* used by the *mORMot* Open Source framework, version 2.

## External Libraries

All `mormot.lib.*.pas` units define direct access to external libraries, like zlib, lizard, curl or openssl. 

We define "external" libraries as some code which is statically linked or dynamically linked into your executable, as dependencies, and are not part of the *mORMot* framework itself and its licensing terms.

Notes:

- The mandatory libraries which are meant to be part of the Operating System - e.g. the Windows API or the `libc`/`pthread` API - are defined in `mormot.core.os`.
- Access to the SQL database client libraries won't be in this folder, but defined as `mormot.db.raw.*` units in the `src/db` folder.

## Thin Wrappers

Those `mormot.lib.*.pas` units are just wrappers to the `c`/`stdcall` external API of the libraries. They are then encapsulated in higher level units, which are meant to be used by the framework.

For instance 

- `mormot.lib.z.pas`/`mormot.lib.openssl11` contains the raw access to the `zlib`/`OpenSSL` API, 
- whereas `mormot.core.zip.pas`/`mormot.core.crypto.openssl` contains the high-level `deflate` and `.zip` file process / encryption and signing using `OpenSSL`.

On Windows, some Operating-System high-level features like Windows HTTP and WebSockets client/server API, or SSPI/SChannel API are also defined in this folder, to leverage `mormot.core.os.pas` focusing on core cross-platform features.


## Units Presentation

### mormot.lib.z

Cross-Platform and Cross-Compiler `zlib` API
- Low-Level ZLib Streaming Access
- Low-Level libdeflate in-memory Compression Library
- Simple Wrapper Functions for Deflate/ZLib Process

FPC Intel-Linux and Win32 use the faster libdeflate for in-memory compression.

### mormot.lib.lizard

Cross-Platform and Cross-Compiler `Lizard` (LZ5) API
- Low-Level Lizard API Process
- `TAlgoLizard TAlgoLizardFast TAlgoLizardHuffman` High-Level Algorithms

### mormot.lib.curl

Cross-Platform and Cross-Compiler `libcurl` API
- CURL Low-Level Constants and Types
- CURL Functions API

## mormot.lib.openssl11

Cross-Platform and Cross-Compiler `OpenSSL` 1.1/ 3.x API
- Dynamic or Static OpenSSL Library Loading
- OpenSSL Library Constants
- OpenSSL Library Types and Structures
- OpenSSL Library Functions
- OpenSSL Helpers
- TLS / HTTPS Encryption Layer using OpenSSL for `mormot.net.sock` / `TCrtSocket`

Implementation notes:
- In respect to OpenSSL 1.0.x, the new 1.1 / 3.x API hide most structures behind getter/setter functions, and does not require complex initialization.
- OpenSSL 1.1 features TLS 1.3, but is now deprecated.
- OpenSSL 3.x is supported as the current major version.
- OpenSSL 1.1 / 3.x API adaptation is done at runtime by dynamic loading.

**Warning:**
- On Windows, the USE_OPENSSL conditional is defined, but the OpenSSL lib*.dll will be loaded at runtime, only if needed, and silently fail if they are not available or in an unexpected version. Therefore, the SChannel layer will be used for TLS support by default, until OpenSslInitialize or OpenSslIsAvailable are called and succeeded.
- We did not enable OpenSSL by default on Windows, because from experience, it is very likely that your executable may find some obsolete dll in your Windows path, if it can't find any suitable dll in its own folder.
- On POSIX, this unit will always try to load OpenSSL at startup, as if FORCE_OPENSSL conditional was defined.
- On Darwin/MacOS, the .dylib supplied by the system are unstable and should not be used. Try e.g. from https://synopse.info/files/OpenSSLMacX64.tgz (for x64) or https://synopse.info/files/OpenSSLMacA64.tgz (for Arm).

**Legal Notice**: as stated by our LICENSE.md terms, make sure that you comply to any restriction about the use of cryptographic software in your country.

### mormot.lib.winhttp

Windows HTTP and WebSockets API Libraries
- `WinINet` API Additional Wrappers
- `http.sys` / HTTP Server API low-level direct access
- `winhttp.dll` Windows API Definitions
- `websocket.dll` Windows API Definitions

### mormot.lib.sspi

Security Support Provider Interface (SSPI) Support on Windows
- Low-Level SSPI/SChannel Functions
- Middle-Level SSPI Wrappers
- High-Level Client and Server Authentication using SSPI e.g. in `mormot.core.rest`
- Lan Manager Access Functions

### mormot.lib.gssapi

Generic Security Service API on POSIX/Linux
- Low-Level `libgssapi_krb5`/`libgssapi.so` Library Access
- Middle-Level GSSAPI Wrappers
- High-Level Client and Server Authentication using GSSAPI e.g. in `mormot.core.rest`

### mormot.lib.gdiplus

Windows GDI+ Graphics Device Interface Support
- GDI+ Shared Types
- GDI+ `TImageAttributes` wrapper
- `TGdiPlus` class for Direct Access to the GDI+ Library
- AntiAliased Rendering of GDI MetaFile

See `mormot.ui.gdiplus.pas` for high-level LCL/VCL pictures support.

### mormot.lib.quickjs

Cross-Platform and Cross-Compiler JavaScript Interpreter
- *QuickJS* Low-Level Constants and Types
- *QuickJS* Functions API
- *QuickJS* to Pascal Wrappers

*QuickJS* is a small and embeddable Javascript engine.
It supports the ES2020 specification including modules, asynchronous generators, proxies and BigInt.
We supply the engine as static binaires (no external `.dll`/`.so` needed), with some fixes and extensions.

### mormot.lib.win7zip

Access to the 7-Zip Compression/Decompression DLL on Windows 
- Low-Level 7-Zip API Definitions
- `I7zReader`/`I7zWriter` High-Level Wrappers

*Can I use the EXE or DLL files from 7-Zip in a commercial application?*

Yes, but you are required to specify in documentation for your application:
- that you used parts of the 7-Zip program,
- that 7-Zip is licensed under the GNU LGPL license and
- you must give a link to www.7-zip.org, where the source code can be found.

*Can I become insane because of directly calling the 7-Zip public dll API?*

Yes, Igor's API is just bloated and crazy complex: the LCL unit has 10,000 lines just for basic archive work. So don't become insane and use our unit. Better be safe than sorry.
