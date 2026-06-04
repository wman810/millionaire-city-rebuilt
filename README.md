# Millionaire City Rebuilt

Millionaire City Rebuilt is a fan-made local revival of the `0.501` Millionaire City Flash client. It runs the original client with a replacement local server, bundled Flash-capable Electron runtime, and local SQLite save storage. The revival is built with TypeScript, Node.js, Express, Electron, and `better-sqlite3`.

This project is not affiliated with Digital Chocolate, Ubisoft, or Facebook.

## Download And Play

For normal play, use a portable release for your operating system:

1. Download the latest `MillionaireCityRebuilt-*-portable-*-x64.zip` from GitHub Releases.
2. Extract the ZIP.
3. Run the included Millionaire City Rebuilt app.

No installer is required.

## Community

Join the [Millionaire City Rebuilt Discord server](https://discord.gg/cr6M7UAh4J).

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
npm run dev:server
```

Then open:

```text
https://127.0.0.1:31804/launcher
```

This requires a browser that still supports Flash. The bundled Electron runtime is the recommended way to play.

## Building

To build from source, install Node.js with npm and a Java runtime first. Node.js 20 and Java 21 are recommended.

1. Install dependencies:

```powershell
npm install
```

2. Prepare the private client copy:

```powershell
npm run prepare-client
```

For running the desktop client in development, run:

```powershell
npm run dev:desktop
```

For running only the local server in development, run:

```powershell
npm run dev:server
```

## Project Layout

- `apps/server`: local HTTP game server, HTTPS Facebook shim, SQLite persistence, and launcher page
- `apps/desktop`: Electron launcher that starts the server and opens the bundled Flash runtime
- `packages/shared`: protocol constants, types, and envelope helpers shared by both apps
- `assets`: recovered game cache served by the local server
- `apps/desktop/assets/flash`: bundled Pepper Flash runtime binaries
- `generated`: generated private SWF copy, SQLite save data, downloaded tools, release runtime files, and local backups
