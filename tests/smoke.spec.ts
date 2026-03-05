import { expect, test } from "@playwright/test";

test("homepage exposes the main booking CTA", async ({ page }) => {
  await page.goto("/");

  await expect(
    page.getByRole("heading", { level: 1, name: /Self-Service Ausschank/i })
  ).toBeVisible();
  await expect(
    page.getByRole("link", { name: /Preisrechner & Reservierung/i }).first()
  ).toBeVisible();
});

test("calculator can switch into bring-your-own-drinks mode", async ({ page }) => {
  await page.goto("/calculator");

  await expect(
    page.getByRole("heading", { level: 1, name: /Preisrechner/i })
  ).toBeVisible();
  await expect(page.locator("#calc-drinks-mode")).toBeVisible();
  await expect(page.locator("#calc-tap-heads-mode")).toBeHidden();

  await page.locator("#bring-own-drinks").check();

  await expect(page.locator("#calc-drinks-mode")).toBeHidden();
  await expect(page.locator("#calc-tap-heads-mode")).toBeVisible();
  await expect(page.getByText("Flat Head")).toBeVisible();
  await expect(page.getByText("Korbfitting")).toBeVisible();
});
