import { parseRobotsTxt, validateRobots } from "@nuxtjs/robots/util";
import { defineEventHandler, getQuery } from "h3";
export default defineEventHandler(async (e) => {
  const { url, mode } = getQuery(e);
  if (!url || typeof url !== "string")
    return { url: "", robotsTxt: "", indexable: false, hints: [], validation: { errors: [], warnings: [], groups: 0, sitemaps: [] }, hasRemoteDebug: false, error: "Missing url query parameter" };
  const baseUrl = url.replace(/\/$/, "");
  if (mode === "debug") {
    const debugUrl = `${baseUrl}/__robots__/debug.json`;
    const response2 = await fetch(debugUrl, {
      headers: { Accept: "application/json" },
      signal: AbortSignal.timeout(1e4)
    }).catch(() => null);
    if (response2?.ok) {
      const json = await response2.json().catch(() => null);
      if (json?.robotsTxt) {
        return {
          ...json,
          url: baseUrl,
          hasRemoteDebug: true
        };
      }
    }
  }
  const robotsUrl = `${baseUrl}/robots.txt`;
  const response = await fetch(robotsUrl, {
    headers: { Accept: "text/plain" },
    signal: AbortSignal.timeout(15e3)
  }).catch((err) => err);
  if (response instanceof Error)
    return { url: baseUrl, robotsTxt: "", indexable: false, hints: [], validation: { errors: [], warnings: [], groups: 0, sitemaps: [] }, hasRemoteDebug: false, error: `Failed to fetch robots.txt: ${response.message}` };
  if (!response.ok)
    return { url: baseUrl, robotsTxt: "", indexable: false, hints: [], validation: { errors: [], warnings: [], groups: 0, sitemaps: [] }, hasRemoteDebug: false, error: `HTTP ${response.status}: ${response.statusText}` };
  const robotsTxt = await response.text();
  const parsed = validateRobots(parseRobotsTxt(robotsTxt));
  const hasBlockAll = parsed.groups.some(
    (g) => g.userAgent.includes("*") && g.disallow.includes("/")
  );
  return {
    url: baseUrl,
    robotsTxt,
    indexable: !hasBlockAll,
    hints: hasBlockAll ? ["robots.txt blocks all crawlers with Disallow: /"] : [],
    validation: {
      errors: parsed.errors,
      warnings: parsed.warnings,
      groups: parsed.groups.length,
      sitemaps: parsed.sitemaps
    },
    hasRemoteDebug: false
  };
});
