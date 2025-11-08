import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        'brand-red': '#990000',
        'dark-bg': '#1a1a1a',
        'light-text': '#ededed',
        'dark-text': '#171717',
      },
      fontFamily: {
        sans: ['var(--font-geist-sans)'],
        mono: ['var(--font-geist-mono)'],
      },
      backgroundImage: {
        'hero-pattern': "url('/images/fundo_restaurante.jpg')",
      }
    },
  },
  plugins: [],
};
export default config;