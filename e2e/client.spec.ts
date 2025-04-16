import { test, expect } from '@playwright/test'

test('client page loads', async ({ page }) => {
  await page.goto('http://localhost:3000/clients')
  await page.getByRole('textbox', { name: 'Email' }).click();
  await page.getByRole('textbox', { name: 'Email' }).fill('superadmin@admin.com');
  await page.getByRole('textbox', { name: 'Password' }).click();
  await page.getByRole('textbox', { name: 'Password' }).fill('superadmin');
  await page.getByRole('button', { name: 'Login' }).click();

  //login and happy case
  await page.getByRole('link', { name: 'Client M' }).click();
  await page.getByRole('link', { name: 'New Client' }).click();
  await page.getByRole('textbox', { name: 'Client name *' }).click();
  await page.getByRole('textbox', { name: 'Client name *' }).fill('test playwrite ');
  await page.getByRole('textbox', { name: 'Contact info' }).click();
  await page.getByRole('textbox', { name: 'Contact info' }).fill('test contect');
  await page.getByRole('button', { name: 'Create Client' }).click();
  await expect(page.locator('h1')).toContainText('Client list')

  //edit
  await page.getByRole('row', { name: 'test playwrite Editdf Version' }).getByRole('img').nth(1).click();
  await page.getByRole('textbox', { name: 'Client name *' }).click();
  await page.getByRole('textbox', { name: 'Client name *' }).fill('test playwrite Edit');
  await page.getByRole('button', { name: 'Update Client' }).click();

  //delete  
  await page.getByRole('row', { name: 'test playwrite Editdf Version' }).getByRole('img').nth(1).click();
  await page.getByRole('button', { name: /delete/i }).click();
  await expect(page.locator('h1')).toContainText('Client list')

  // คลิกปุ่มลบใน row ที่มีชื่อ client
  await page
    .getByRole('row', { name: 'test playwrite Edit test' })
    .getByRole('button', { name: /delete/i }) // ปรับ label ตามจริง
    .click();
  
  // ดักจับ dialog ก่อนจะคลิกปุ่มที่มี confirm
  page.once('dialog', async dialog => {
    console.log('Dialog message:', dialog.message())  // debug ดูข้อความ
    await dialog.accept()  // หรือ dialog.dismiss() ถ้าต้องการยกเลิก
  });
  
  // ตรวจสอบว่า client ถูกลบแล้ว เช่น ไม่เจอชื่อ client ในตาราง
  await expect(page.getByText('test playwrite Edit test')).not.toBeVisible();
  
  // หรือ fallback: ยังอยู่ในหน้า client list
  await expect(page.locator('h1')).toContainText('Client list')
});
  
