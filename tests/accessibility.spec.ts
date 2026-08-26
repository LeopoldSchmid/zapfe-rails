import AxeBuilder from "@axe-core/playwright";
import { expect, test, type Page } from "@playwright/test";

const WCAG_TAGS = ["wcag2a", "wcag2aa", "wcag21aa", "wcag22aa"];

async function expectNoWcagViolations(page: Page) {
  const results = await new AxeBuilder({ page }).withTags(WCAG_TAGS).analyze();
  expect(results.violations).toEqual([]);
}

async function signIn(page: Page) {
  await page.goto("/admin/login");
  await page.getByLabel("E-Mail").fill("e2e-admin@example.com");
  await page.getByLabel("Passwort").fill("correct-horse-battery-staple");
  await page.getByRole("button", { name: /Anmelden/i }).click();

  await page.goto("/admin");
  await expect(page.getByRole("heading").first()).toBeVisible();
}

test("public pages satisfy automated WCAG 2.2 AA checks", async ({ page }) => {
  for (const path of ["/", "/calculator", "/contact"]) {
    await page.goto(path);
    await expectNoWcagViolations(page);
  }
});

test("authenticated admin satisfies automated WCAG checks", async ({ page }) => {
  await signIn(page);
  await expectNoWcagViolations(page);
});

test("mobile navigation supports keyboard, Escape and focus return", async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto("/");
  const toggle = page.getByRole("button", { name: "Menü öffnen" });
  await toggle.focus();
  await page.keyboard.press("Enter");
  await expect(toggle).toHaveAttribute("aria-expanded", "true");
  await expect(page.getByRole("button", { name: "Menü schließen" })).toBeFocused();
  await page.keyboard.press("Tab");
  await expect(page.getByRole("link", { name: "Startseite" }).last()).toBeFocused();
  await page.keyboard.press("Escape");
  await expect(toggle).toHaveAttribute("aria-expanded", "false");
  await expect(toggle).toBeFocused();
});

test("reduced motion prevents automatic video playback", async ({ page }) => {
  await page.emulateMedia({ reducedMotion: "reduce" });
  await page.goto("/events");
  const video = page.locator("video").first();
  await video.scrollIntoViewIfNeeded();
  await expect(page.getByRole("button", { name: "Video abspielen" }).first()).toBeVisible();
  await expect.poll(() => video.evaluate((element: HTMLVideoElement) => element.paused)).toBe(true);
});
