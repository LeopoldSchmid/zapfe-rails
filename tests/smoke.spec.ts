import { expect, test } from "@playwright/test";

test("homepage exposes the main booking CTA", async ({ page }) => {
  await page.goto("/");

  await expect(
    page.getByRole("heading", { level: 1, name: /Frisch gezapfte Getränke/i })
  ).toBeVisible();
  await expect(
    page.getByRole("link", { name: /Event, temporär/i })
  ).toBeVisible();
  await expect(
    page.getByRole("link", { name: /Betrieb, dauerhaft/i })
  ).toBeVisible();
});

test("calculator can switch into bring-your-own-drinks mode", async ({ page }) => {
  await page.goto("/calculator");

  await expect(
    page.getByRole("heading", { level: 1, name: /Preis kalkulieren/i })
  ).toBeVisible();
  await expect(page.locator("#calc-drinks-mode")).toBeVisible();
  await expect(page.locator("#calc-own-drinks-note")).toBeHidden();

  await page.locator("#bring-own-drinks").setChecked(true, { force: true });

  await expect(page.locator("#calc-drinks-mode")).toBeHidden();
  await expect(page.locator("#calc-own-drinks-note")).toBeVisible();
  await expect(
    page.getByText("Du kümmerst dich um deine Getränke selbst.", { exact: false })
  ).toBeVisible();
});

test("calculator deletes legacy contact PII and never persists form fields", async ({ page }) => {
  await page.addInitScript(() => {
    window.localStorage.setItem("zapfe_calculator_form_v1", JSON.stringify({
      "inquiry[first_name]": "Legacy",
      "inquiry[email]": "legacy@example.test",
      "inquiry[phone]": "+4912345"
    }));
  });

  await page.goto("/calculator");
  await page.locator("#inquiry_first_name").fill("Fresh");

  const persisted = await page.evaluate(() => window.localStorage.getItem("zapfe_calculator_form_v1"));
  expect(persisted).toBeNull();
});

test("admin service worker is scoped and activates updates only on request", async ({ request }) => {
  const response = await request.get("/service-worker.js");
  expect(response.ok()).toBeTruthy();
  const source = await response.text();
  const installHandler = source.split('self.addEventListener("message"')[0];

  expect(source).toContain('event.data?.type === "SKIP_WAITING"');
  expect(source).toContain("self.skipWaiting()");
  expect(installHandler).not.toContain("self.skipWaiting()");
  expect(source).toContain('pathname !== "/admin/manifest.webmanifest"');
});
