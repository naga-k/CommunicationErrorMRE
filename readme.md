# Communication Error MRE

A minimal reproduction example showing communication between a Flutter web app and a Node.js editor server.

## Prerequisites

- Node.js and npm
- Flutter SDK
- Chrome browser
- TypeScript (for editor server)

## Project Structure

- `editor-server/` - Node.js/TypeScript server component
- `minimal_repro/` - Flutter web application

## Setup & Running

### 1. Editor Server

First, start the editor server:

```bash
cd editor-server
npm install
npm run start
```

The editor server will run at `http://localhost:3005`

### 2. Flutter Web App

In a new terminal, run the Flutter web app:

```bash
cd minimal_repro
flutter pub get
flutter run -d chrome --web-port 5000
```

The Flutter app will open in Chrome at `http://localhost:5000`

## Testing Communication

1. Once both servers are running, you'll see a button labeled "Send Message" in the Flutter web app
2. Click the button to test communication between the Flutter app and editor server
3. Check the debug console for message status

## Development

- The main Flutter code is in `minimal_repro/lib/main.dart`
- The editor server code is in `editor-server/server.ts`