import { parseRobotsTxt, validateRobots } from "@nuxtjs/robots/util";
import { defineEventHandler, getQuery } from "h3";
import { getSiteConfig } from "#site-config/server/composables/getSiteConfig";
import { getSiteRobotConfig } from "../../composables/getSiteRobotConfig.js";
import { useRuntimeConfigNuxtRobots } from "../../composables/useRuntimeConfigNuxtRobots.js";
export default defineEventHandler(async (e) => {
  const runtimeConfig = useRuntimeConfigNuxtRobots(e);
  const { indexable, hints } = getSiteRobotConfig(e);
  const siteConfig = getSiteConfig(e);
  const robotsTxt = await e.$fetch("/robots.txt", {
    query: getQuery(e)
  });
  const parsed = validateRobots(parseRobotsTxt(robotsTxt));
  return {
    robotsTxt,
    indexable,
    hints,
    runtimeConfig,
    siteConfig: {
      url: siteConfig.url,
      env: siteConfig.env,
      indexable: siteConfig.indexable
    },
    validation: {
      errors: parsed.errors,
      warnings: parsed.warnings,
      groups: parsed.groups.length,
      sitemaps: parsed.sitemaps
    }
  };
});
