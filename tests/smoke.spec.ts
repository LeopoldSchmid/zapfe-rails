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
    page.getByRole("heading", { level: 1, name: /Preis grob einschätzen/i })
  ).toBeVisible();
  await expect(page.locator("#calc-drinks-mode")).toBeVisible();
  await expect(page.locator("#calc-own-drinks-note")).toBeHidden();

  await page.locator("#bring-own-drinks").setChecked(true, { force: true });

  await expect(page.locator("#calc-drinks-mode")).toBeHidden();
  await expect(page.locator("#calc-own-drinks-note")).toBeVisible();
  await expect(
    page.getByText("Du bringst die Getränke selbst mit.", { exact: false })
  ).toBeVisible();
});
