# CropCare

**Healthy Crops. Better Harvests.**  
**ఆరోగ్యకరమైన పంటలు, మెరుగైన దిగుబడి.**

A runnable Flutter Android/web application and FastAPI backend for tomato crop care. Designed in forest green, warm ivory and sage with bundled photography, an original leaf-scanner identity, Manrope and Noto Sans Telugu.

## What is included

- Splash, language selection, three onboarding pages, guest access, registration/sign-in, optional location entry, home, crop selection, scanner, preview, processing, results, disease library/details, history, profile and help.
- English/Telugu ARB localization, persisted language/location, live camera preview and capture, gallery selection, flash where hardware supports it, EXIF stripping and image validation.
- Explicitly selected deterministic demo scenarios. No random or image-based fake diagnoses. Demo history and its images persist on the device and can be deleted.
- Real backend registration and login, PBKDF2 password hashing, hashed expiring bearer sessions, owner-scoped scan records and image deletion. Tokens are held in app memory, not browser local storage.
- Optional real Keras inference with mandatory training metadata checks. No retraining. MySQL in Docker; SQLite for convenient local development.
- CI checks, a manually triggered GitHub Pages deployment, Dockerfiles and a MySQL/API/web Compose stack.

## Start the frontend

Tested with Flutter **3.44.8**, Dart **3.12.2**. Install Flutter and the Android SDK for Android development. The Flutter SDK must be on PATH.

```powershell
cd frontend
flutter pub get
flutter run -d chrome --web-port 8080
```

Choose a language, continue through onboarding and select **Continue as guest**. No server or account is required to demonstrate the application. Profile lets you change the language and backend address.

### Android emulator

Start an Android emulator from Android Studio's Device Manager, then:

```powershell
flutter doctor
flutter devices
flutter run -d YOUR_DEVICE_ID --dart-define=API_URL=http://10.0.2.2:8000
```

### Physical Android device

Enable Developer options and USB debugging, connect the phone, accept its debugging prompt and run `flutter devices`. For a locally running backend:

```powershell
adb reverse tcp:8000 tcp:8000
flutter run -d YOUR_DEVICE_ID --dart-define=API_URL=http://127.0.0.1:8000
```

Camera and location permissions are requested only when the corresponding action is chosen. Gallery uses the system picker. Location can always be skipped. HTTP is permitted only for localhost/emulator hosts; deployed servers must use HTTPS. Browser camera/location also require HTTPS or localhost.

## Start the backend

Use Python **3.11** for the TensorFlow deployment path. The non-ML API also works with Python 3.13.

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\python -m pip install -r requirements.txt
.\.venv\Scripts\python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Linux/macOS: use `.venv/bin/python` instead. Run from `backend/` so the default SQLite database is created there. API documentation: [localhost:8000/docs](http://localhost:8000/docs). Health/model readiness: [localhost:8000/health](http://localhost:8000/health).

Default allowed browser origins are `http://localhost:8080` and `http://127.0.0.1:8080`. Set `CORS_ORIGINS` to a comma-separated list of exact frontend origins for other ports or deployments. Set `DATABASE_URL` to a SQLAlchemy MySQL URL to use an existing database. The local command does not automatically load `.env`; Docker Compose does.

Registration asks for name, mobile, optional email and a password of at least 10 characters. There is no OTP, email verification or password recovery service. These are real locally/server-stored accounts, not simulated login. Use guest mode when the server is unavailable.

## Connect the existing model

The original model and disease JSON were **not present in the supplied workspace**. They have not been recreated or replaced. Live predictions return `503` until configured; the frontend will refuse to switch to live mode while readiness is false.

1. Place your original `crop_disease_model.keras` in `backend/models/`.
2. Export the exact class order, preprocessing and resize behavior from the original training notebook into `backend/models/model_config.json`. Follow [the model configuration guide](backend/models/README.md). Never copy the library display order as a guessed class order.
3. Install `requirements-ml.txt` in a compatible environment, then restart the server.
4. Verify `/health` reports `live_inference: true`.
5. Register/sign in from the app, then enable **Live mode** under Profile.

Only tomato is supported. There is no leaf/non-leaf detector, calibrated uncertainty estimate or out-of-distribution rejection. Confidence is a model score, not the probability of a correct diagnosis. The UI's high/medium/low buckets (85% / 60%) are presentation thresholds, not validated agronomic decision thresholds.

### Original disease database integration

The bundled ten-entry database is a clearly labelled educational placeholder, not the original `tomato_disease_database.json`. Preserve your source JSON and map it into the shared schema used in `backend/app/data/diseases.json` and `frontend/assets/data/diseases.json`:

`id`, `name`, `category`, `scientific`, `symptoms`, `symptoms_te`, `verified`, `source`.

Class IDs must match the verified model configuration. Replace source links with entry-specific expert-reviewed sources. The current disease names remain English in Telugu mode until verified Telugu terminology is supplied. The rest of the interface is localized. Do not claim local validation merely by changing a boolean. `scripts/build_data.py` regenerates the **starter** data and ARB files; do not run it over your reviewed replacements.

## Push to GitHub

Create an empty GitHub repository, then run these commands from this project root:

```powershell
git init
git add .
git commit -m "Build CropCare Flutter app and FastAPI backend"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/cropcare.git
git push -u origin main
```

The `.gitignore` excludes databases, environment secrets, signing keys, virtual environments and model weights. Review `git status` before pushing. Keep `frontend/pubspec.lock` committed for reproducible package resolution. No remote repository has been created or pushed by this project setup.

## Deployment

### Frontend demo: GitHub Pages

1. Push the project to GitHub.
2. Open repository **Settings → Pages → Build and deployment → Source → GitHub Actions**.
3. Under **Actions**, run **Deploy CropCare demo to GitHub Pages**.
4. The workflow publishes the Flutter web build with the repository's correct base path. The deployment job returns the public URL.
5. Optionally set the repository Actions variable `API_URL` to your HTTPS backend address. Configure that frontend origin in the backend's `CORS_ORIGINS`. The address can also be changed in Profile.

GitHub Pages hosts only the frontend. It does **not** run Python, MySQL or TensorFlow. Demo mode needs no backend. A repository rename or custom domain may require adjusting the workflow base path. The web version needs an initial network load; offline use after a browser restart is not guaranteed. Installed Android demo functionality works offline.

### Complete stack: Docker Compose

Requires Docker with Compose. From the root, copy `.env.example` to `.env` and replace both database passwords. Use long URL-safe random values; reserved URL characters in `MYSQL_PASSWORD` need encoding in `DATABASE_URL`.

```powershell
Copy-Item .env.example .env
cd frontend
flutter build web --release --no-web-resources-cdn --dart-define=API_URL=
cd ..
docker compose up --build -d
```

Open [localhost:8080](http://localhost:8080). Nginx serves the frontend and forwards `/api/` and `/health` to FastAPI. The empty `API_URL` selects same-origin requests. MySQL is private to the Compose network and stores data in a named volume. The API's development port binds only to host loopback.

For a server deployment, place a TLS reverse proxy in front of port 8080 and use your HTTPS domain. Configure persistent storage/backups, rotate secrets and restrict host ports. Enable `WITH_ML=true` in `.env` to install TensorFlow in the backend image; mount the model/configuration in `backend/models/`. This project requires no paid API, but a hosting provider may charge for compute or storage. No hosting account was provisioned and no public deployment has been made.

The API uses one worker and a per-process authentication limiter. For multiple replicas, replace it with a shared limiter at the edge. It currently creates tables on startup; introduce migrations before modifying an existing production schema. Plan production account verification/recovery, backup retention, monitoring and agronomic validation before using it as a public advisory service.

### Android packages

```powershell
cd frontend
flutter build apk --debug
```

APK: `frontend/build/app/outputs/flutter-apk/app-debug.apk`. For store publication, configure your own upload keystore and release signing in `android/app/build.gradle.kts`, then use `flutter build appbundle --release`. The generated template currently uses a debug signing key for release and is **not store-ready**. Never commit signing keys or passwords.

## Checks

```powershell
cd frontend
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn
cd ../backend
.\.venv\Scripts\python -m unittest discover -s tests -v
```

Tests cover deterministic local storage/deletion, malformed and oversized image input, localization parity and a narrow-screen Telugu flow, plus backend authentication, rate limiting, account isolation, image deletion and unavailable-model behavior. Inference is mocked only inside tests; real-model accuracy cannot be checked without the original artifacts.

## Project layout

```text
frontend/lib/core/theme/      design tokens and Material theme
frontend/lib/l10n/            English/Telugu ARB resources + delegate
frontend/lib/models/          disease and scan models
frontend/lib/repositories/    interchangeable local/live scan repositories
frontend/lib/services/        app state and HTTP client
frontend/lib/screens/         connected UI flows
frontend/lib/widgets/         shared components and original brand
frontend/assets/             bundled photo, logo, fonts and disease data
backend/app/                 FastAPI, SQLAlchemy, auth and inference
backend/models/              bring your original model and metadata
backend/tests/               API and persistence integration tests
.github/workflows/           CI and optional Pages deployment
```

## Current limits and privacy

- Demo history is limited to 20 compressed observations to keep preferences/browser storage bounded. Delete old records when full. Clearing app/browser data also removes local history. Guest data is device-scoped, not account-private on a shared device.
- Live scan photos are uploaded and retained with the authenticated account. Scan deletion deletes the image record too; operational backups must follow the operator's retention policy. Uploaded EXIF is stripped. Location is stored only locally and is not attached to scan uploads.
- No complete India administrative dataset was supplied. State suggestions prioritize Andhra Pradesh and Telangana; district/mandal/village use free text. GPS stores coordinates, with no guessed reverse-geocoded village.
- There are no verified disease photographs or verified Telugu disease names in this starter. Library icons are symbolic; upcoming crops are disabled. The bundled cultivation photo is not represented as an Indian location. See [asset attribution](frontend/assets/ATTRIBUTION.md).
- No pesticide/dosage recommendations, expert-contact service, invented helplines, weather API or paid maps. Always verify suspected disease with a local agricultural expert.
- Real camera hardware, browser permission behaviors, flash availability, MySQL container deployment and real TensorFlow inference require their respective environments. Passing widget/API tests is not a substitute for those device/deployment checks.
- Local Android build attempt: Gradle's distribution download timed out. Flutter Doctor also reports unaccepted Android SDK licenses. Review and accept the applicable licenses yourself with `flutter doctor --android-licenses`, restore access to the Gradle distribution host, and rerun the APK command. No APK has been produced in this environment.
