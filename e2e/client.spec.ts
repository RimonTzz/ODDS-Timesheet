import { test, expect } from '@playwright/test';

test('client page loads', async ({ page }) => {
  await page.goto('http://localhost:3000/clients');
  await page.getByRole('textbox', { name: 'Email' }).click();
  await page.getByRole('textbox', { name: 'Email' }).fill('superadmin@admin.com');
  await page.getByRole('textbox', { name: 'Password' }).click();
  await page.getByRole('textbox', { name: 'Password' }).fill('superadmin');
  await page.getByRole('button', { name: 'Login' }).click();

  // login and happy case
  await page.getByRole('link', { name: 'Client M' }).click();
  await page.getByRole('link', { name: 'New Client' }).click();
  await page.getByRole('textbox', { name: 'Client name *' }).click();
  await page.getByRole('textbox', { name: 'Client name *' }).fill('test playwrite ');
  await page.getByRole('textbox', { name: 'Contact info' }).click();
  await page.getByRole('textbox', { name: 'Contact info' }).fill('test contect');
  await page.getByRole('button', { name: 'Create Client' }).click();
  await expect(page.locator('h1')).toContainText('Client list');
  await expect(page.locator('tr', { hasText: 'test playwrite ' })).toBeVisible();

  // edit
  await page.locator('tr:nth-child(9) > .table-actions > div > .solid').click();
  await page.getByRole('textbox', { name: 'Client name *' }).click();
  await page.getByRole('textbox', { name: 'Client name *' }).fill('test playwrite Edit');
  await page.getByRole('button', { name: 'Update Client' }).click();
  await expect(page.locator('tr', { hasText: 'test playwrite Edit' })).toBeVisible();
  
});




test('client delete dialog-alert', async ({ page }) => {
  await page.goto('http://localhost:3000/clients');
  await page.getByRole('textbox', { name: 'Email' }).click();
  await page.getByRole('textbox', { name: 'Email' }).fill('superadmin@admin.com');
  await page.getByRole('textbox', { name: 'Password' }).click();
  await page.getByRole('textbox', { name: 'Password' }).fill('superadmin');
  await page.getByRole('button', { name: 'Login' }).click();

  page.on('dialog', async dialog => {
    expect(dialog.type()).toContain('confirm');
    expect(dialog.message()).toContain('Are you sure you want to delete this client?');
    await dialog.accept();
  });

  await page.locator("//tbody/tr[9]/td[3]/form[1]/button[1]/img[2]").click();

  await expect(page.locator('tr', { hasText: 'test playwrite Edit' })).not.toBeVisible();

  await expect(page.locator('h1')).toContainText('Client list');
});