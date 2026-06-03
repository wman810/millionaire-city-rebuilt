# Millionaire City Rebuilt

Millionaire City Rebuilt is a fan-made local revival of the `0.501` Millionaire City Flash client. It runs the original client with a replacement local server, bundled Flash-capable Electron runtime, and local SQLite save storage.

This project is not affiliated with Digital Chocolate, Ubisoft, or Facebook.

## Download And Play

For normal play, use the portable Windows release:

1. Download the latest `MillionaireCityRebuilt-*-portable-win-x64.zip` from GitHub Releases.
2. Extract the ZIP.
3. Run `Millionaire City Rebuilt.exe`.

No installer is required.

## Community

Join the Discord server:

```text
discord.gg/cr6M7UAh4J
```

## Save Location

Your local save is stored under:

```text
generated/data
```

Back up this folder before deleting files, resetting your city, or testing experimental builds.

## Browser Play

The portable release is designed to use the bundled Electron client. Do not run the portable EXE and another browser client at the same time, because both would use the same local save.

Advanced users building from source can start only the local server:

```powershell
cmd /c npm run dev:server
```

Then open:

```text
https://127.0.0.1:31804/launcher
```

This requires a browser that still supports Flash. The bundled Electron runtime is the recommended way to play.

## Build From Source

GitHub source downloads do not include `node_modules/`. Run the install step before any `npm run ...` command.

1. Install dependencies:

```powershell
cmd /c npm install
```

2. Prepare the private client copy:

```powershell
cmd /c npm run prepare-client
```

3. Start the desktop app:

```powershell
cmd /c npm run dev:desktop
```

## Checks

The project can be built and tested after dependencies are installed:

```powershell
cmd /c npm run build
cmd /c npm run test
```

To build the portable Windows ZIP:

```powershell
cmd /c npm run package:win
```

## Project Layout

- `apps/server`: local HTTP game server, HTTPS Facebook shim, SQLite persistence, and launcher page
- `apps/desktop`: Electron launcher that starts the server and opens the bundled Flash runtime
- `packages/shared`: protocol constants, types, and envelope helpers shared by both apps
- `assets`: recovered game cache served by the local server
- `apps/desktop/assets/flash`: bundled Pepper Flash runtime binaries
- `generated`: generated private SWF copy, SQLite save data, downloaded tools, release runtime files, and local backups

## Runtime Model

The original SWF still depends on browser `ExternalInterface`, legacy Facebook endpoints, and a Flash-capable Chromium runtime. The revival handles this by:

- serving a private copy of `Dollars.swf` from `generated/client/Dollars.private.swf`
- exposing a local HTTPS Facebook shim for hardcoded `graph.facebook.com` and `api.facebook.com` calls
- launching Electron `10.4.7` with bundled Pepper Flash enabled

The generated private SWF copy is recreated locally by `npm run prepare-client`.

## Dependency Warnings

`npm audit` reports advisories against `electron@10.4.7`. That version is intentionally pinned because newer Electron releases removed the Pepper Flash plugin path this client depends on. Do not run `npm audit fix --force`; it upgrades Electron to a modern version that breaks the Flash runtime.

Some deprecation warnings also come from Electron/native packaging tooling. The release packaging scripts invoke `electron-builder@26.8.1` on demand with `npx`, so packaging may print warnings from its internal dependency stack.
