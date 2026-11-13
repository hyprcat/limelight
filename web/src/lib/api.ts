// The landing page only reads one thing from the backend: profile pictures,
// served by the core API at /user_eng/get_media_url/<username>.
export const API_URL =
  process.env.NEXT_PUBLIC_LIMELIGHT_API_URL ?? "https://cloud.limelight.sh";

export const profilePicture = (username: string) =>
  `${API_URL}/user_eng/get_media_url/${username}`;
