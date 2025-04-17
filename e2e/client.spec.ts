import { test, expect } from '@playwright/test';

test.describe('Client Management', () => {
  // Setup login before each test
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:3000');
    await page.getByRole('textbox', { name: 'Email' }).click();
    await page.getByRole('textbox', { name: 'Email' }).fill('superadmin@admin.com');
    await page.getByRole('textbox', { name: 'Password' }).click();
    await page.getByRole('textbox', { name: 'Password' }).fill('superadmin');
    await page.getByRole('button', { name: 'Login' }).click();
  });

  test('client created', async ({ page }) => {
    await page.getByRole('link', { name: 'Clients' }).click();
    await page.getByRole('link', { name: 'New Client' }).click();
    await page.getByRole('textbox', { name: 'Client name *' }).click();
    await page.getByRole('textbox', { name: 'Client name *' }).fill('test playwrite');
    await page.getByRole('textbox', { name: 'Contact info' }).click();
    await page.getByRole('textbox', { name: 'Contact info' }).fill('test contact');
    await page.getByRole('button', { name: 'Create Client' }).click();
    await expect(page.getByRole('row').filter({ hasText: 'test playwrite' }).first())
      .toBeVisible({ timeout: 5000 });
  });
  
  test('client Edited', async ({ page }) => {
    await page.getByRole('link', { name: 'Clients' }).click();
    await page.waitForSelector('table');
    
    // ใช้ selector แบบเดิมที่ทำงานได้
    await page.locator('tr:nth-child(8) > .table-actions > div > .solid').click();

    await page.getByRole('textbox', { name: 'Client name *' }).click();
    await page.getByRole('textbox', { name: 'Client name *' }).fill('test playwrite Edit');
    await page.getByRole('button', { name: 'Update Client' }).click();
    
    await expect(page.getByRole('row').filter({ hasText: 'test playwrite Edit' }).first())
      .toBeVisible({ timeout: 5000 });
  });

  test('client delete dialog-alert', async ({ page }) => {
    await page.getByRole('link', { name: 'Clients' }).click();
    await page.waitForSelector('table');

    page.on('dialog', async dialog => {
      expect(dialog.type()).toContain('confirm');
      expect(dialog.message()).toContain('Are you sure you want to delete this client?');
      await dialog.accept();
    });

    // ใช้ selector แบบเดิมที่ทำงานได้
    await page.locator('tr:nth-child(8) > .table-actions > form > button').click();

    await expect(page.getByRole('row').filter({ hasText: 'test playwrite Edit' }))
      .not.toBeVisible({ timeout: 5000 });
  });
});