import { defineConfig } from '@playwright/test';

export default defineConfig({
  timeout: 60000,
  expect: {
    timeout: 10000
  },
}); 