import { expect, test } from "@playwright/test";

test.describe("architecture review quest", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/architecture-review");
    await page.evaluate(() => window.localStorage.clear());
    await page.reload();
  });

  test("filters findings, explains a quest and persists understood progress", async ({ page }) => {
    await expect(page.getByRole("heading", { level: 1, name: /Mach die App produktionsreif/i })).toBeVisible();
    await expect(page.locator("[data-review-quest-target='card']")).toHaveCount(54);

    await page.getByRole("button", { name: "Boss", exact: true }).click();
    await expect(page.locator("[data-review-quest-target='card']:visible")).toHaveCount(3);

    await page.locator("[data-review-quest-target='card']:visible .review-card__main").first().click();
    const dialog = page.getByRole("dialog");
    await expect(dialog).toBeVisible();
    await expect(dialog.getByRole("heading", { name: /Verwundbare Runtime-Abhängigkeiten/i })).toBeVisible();
    await dialog.getByRole("button", { name: /Als verstanden markieren/i }).click();
    await expect(page.getByText("100 XP gesammelt")).toBeVisible();

    await page.getByRole("button", { name: "Dialog schließen" }).click();
    await page.reload();
    await expect(page.getByText("100 XP gesammelt")).toBeVisible();
  });

  test("remains usable on a narrow screen", async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.reload();

    await expect(page.getByRole("heading", { level: 1 })).toBeVisible();
    await page.getByPlaceholder(/ID, Risiko oder Maßnahme/i).fill("LocalStorage");
    await expect(page.locator("[data-review-quest-target='card']:visible")).toHaveCount(1);
    await expect(page.getByRole("heading", { name: /Kontakt-PII bleibt unbegrenzt im Browser/i })).toBeVisible();
  });
});
