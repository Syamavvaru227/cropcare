# Deploy CropCare on Render

The root `render.yaml` deploys one **free Docker web service** serving both Flutter web and FastAPI at the same HTTPS address. The frontend uses same-origin API requests, so there is no hardcoded Render hostname.

[Create the Render Blueprint](https://dashboard.render.com/blueprint/new?repo=https%3A%2F%2Fgithub.com%2FSyamavvaru227%2Fcropcare)

1. Sign in to Render and connect the GitHub repository if requested.
2. Review the Blueprint: service `cropcare`, Docker runtime, **Free** compute, `/health` health check.
3. Deploy. Open the service's returned `https://…onrender.com` address when it is live.
4. `/` serves the frontend; `/health` reports readiness; `/docs` exposes API documentation.

The Docker build pins Flutter 3.44.8, uses the committed package lockfile, compiles assets for `/`, and installs only Python dependencies in the runtime image. It respects Render's `PORT`. The existing GitHub Pages deployment is independent and unchanged.

## Free demo limitations

- Free Render web services have **ephemeral storage** and can sleep when idle. Accounts and server-side scan records in this SQLite configuration disappear on restarts/redeploys. The Render build displays this warning on sign-in and registration. Device-local guest history is unaffected.
- Do not use this configuration to retain important farmer records. Connect an external persistent MySQL database through `DATABASE_URL`, or choose a paid persistent disk separately. This Blueprint creates no paid service, disk or database.
- The original trained model and verified metadata are still absent. Live prediction remains disabled; guest scanning is explicitly simulated. Do not install TensorFlow on a small free instance without checking its memory needs.
- Future pushes auto-deploy after GitHub CI succeeds when the service is connected through Git credentials.

The initial SDK download and build may take several minutes. If automatic deployment is blocked, inspect the Render build log rather than changing to a paid instance automatically.

Sources: [Render free limits](https://render.com/docs/free), [Blueprint specification](https://render.com/docs/blueprint-spec).
