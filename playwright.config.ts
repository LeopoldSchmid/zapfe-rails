import { defineConfig, devices } from "@playwright/test";

const playwrightPort = process.env.PLAYWRIGHT_PORT || "3200";
const baseURL = `http://127.0.0.1:${playwrightPort}`;
const playwrightDatabase = "sqlite3:storage/playwright.sqlite3";

export default defineConfig({
  testDir: "./tests",
  timeout: 20 * 1000,
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [["list"], ["html", { open: "never" }]],
  use: {
    headless: !process.env.PLAYWRIGHT_HEADED,
    trace: "on-first-retry",
    baseURL,
    actionTimeout: 10 * 1000,
    navigationTimeout: 15 * 1000,
    locale: "de-DE",
    timezoneId: "Europe/Berlin",
    extraHTTPHeaders: {
      "Accept-Language": "de-DE,de;q=0.9,en;q=0.8"
    },
    launchOptions: {
      args: ["--lang=de-DE"]
    }
  },
  projects: [
    {
      name: "chromium",
      use: {
        ...devices["Desktop Chrome"]
      }
    }
  ],
  webServer: process.env.PLAYWRIGHT_SKIP_WEBSERVER
    ? undefined
    : {
        command: `DATABASE_URL=${playwrightDatabase} RAILS_ENV=test bin/rails db:prepare && DATABASE_URL=${playwrightDatabase} RAILS_ENV=test bin/rails runner 'user = AdminUser.find_or_initialize_by(email: "e2e-admin@example.com"); user.assign_attributes(name: "E2E Admin", password: "correct-horse-battery-staple", role: "owner", active: true, mfa_secret_ciphertext: nil, mfa_enabled_at: nil, mfa_last_used_at: nil, mfa_recovery_code_digests: []); user.save!' && DATABASE_URL=${playwrightDatabase} RAILS_ENV=test bin/rails server -b 127.0.0.1 -p ${playwrightPort}`,
        url: baseURL,
        reuseExistingServer: !process.env.CI,
        timeout: 45 * 1000
      }
});
