import { expect, test } from "@playwright/test";

test.use({
  viewport: { width: 390, height: 844 },
  isMobile: true,
  hasTouch: true
});

test("cta preview renders all three study directions", async ({ page }) => {
  await page.goto("/cta-preview");

  await expect(
    page.getByRole("heading", { level: 1, name: /Frisch gezapfte Getränke zur Selbstbedienung/i })
  ).toBeVisible();
  await expect(page.getByRole("heading", { level: 2, name: "Compact Pill" })).toBeVisible();
  await expect(page.getByRole("heading", { level: 2, name: "Split Button" })).toBeVisible();
  await expect(page.getByRole("heading", { level: 2, name: "Mini Card CTA" })).toBeVisible();

  await page.screenshot({ path: "/tmp/cta-preview-mobile.png", fullPage: true });
});
