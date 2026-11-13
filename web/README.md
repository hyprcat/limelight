# LimeLight website

The public landing page for LimeLight Social, built with Next.js 14, React 18 and Tailwind CSS.
It is one page that explained the product to creators and linked to the app.

It was written in July and August 2024 and is published as it was, with the folders tidied.
It is not maintained and may not build against current toolchains.

## What is on the page

| Section | Where |
| --- | --- |
| Header with navigation and a "Get started" button | `src/components/sections/header.tsx` |
| Opening headline, one-paragraph pitch and download button | `src/components/sections/spotlight.tsx` |
| Partner logo strip | `src/app/page.tsx` |
| "Made for Creators. By Creators." with four points about the product | `src/components/sections/creator-pitch.tsx` |
| Feature grid with five animated cards: content types, points and leaderboards, Hazel AI, lounges, feedback | `src/components/sections/features.tsx` |
| "LimeLight Stars", a grid of featured creators | `src/components/sections/star-creators.tsx` |
| FAQ | `src/components/sections/faq.tsx` |
| Closing line with a particle effect | `src/components/sections/closing-hero.tsx` |
| Footer | `src/components/sections/footer.tsx` |

## Structure

```
src/
  app/                  layout, the page, global styles
  components/sections/  the page sections listed above
  components/ui/        building blocks copied from component libraries (see below)
  lib/api.ts            backend base URL and the profile picture URL
  lib/utils.ts          class name helper
public/assets/          company logo and partner logos
```

## How it talks to the backend

It only loads creator profile pictures, from `user_eng/get_media_url/<username>` on the API in [`../core`](../core).
The base URL is read from `NEXT_PUBLIC_LIMELIGHT_API_URL` and defaults to the old production host, which is offline.

## Configure and build

```
cp .env.example .env.local   # optional, set NEXT_PUBLIC_LIMELIGHT_API_URL
npm install
npm run dev
```

`npx tsc --noEmit` passes with the versions in `package-lock.json`. There are no secrets in this project.

## Notes

- The files in `src/components/ui/` are adapted from [shadcn/ui](https://ui.shadcn.com) (accordion, button, navigation menu), [Aceternity UI](https://ui.aceternity.com) (bento grid, hero highlight, layout grid, sparkles, spotlight) and [Magic UI](https://magicui.design) (animated grid pattern). The sections and copy are LimeLight's own.
- The creators featured on the live site are replaced here by placeholder usernames (`creator_one` to `creator_four`).
- The partner logos in `public/assets/` are trademarks of their owners and are not covered by this repository's licence.
- The download button still points at a placeholder link (`https://your-link.com`).
