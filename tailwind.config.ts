/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './app/**/*.{js,ts,jsx,tsx}',
    './teams/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        background: '#0F0F1E',
        'card-bg': 'rgba(123, 158, 240, 0.08)',
        'card-border': 'rgba(123, 158, 240, 0.15)',
      },
    },
  },
  plugins: [],
}
