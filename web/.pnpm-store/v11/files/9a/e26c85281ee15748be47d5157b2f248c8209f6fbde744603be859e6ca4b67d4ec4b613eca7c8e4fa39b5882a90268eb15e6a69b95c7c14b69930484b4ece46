import { defineEventHandler, getQuery } from "h3";
import { withQuery } from "ufo";
import { getPathRobotConfig } from "../../composables/getPathRobotConfig.js";
import { extractRobotsMetaFromHtml } from "../../util/extractRobotsMetaFromHtml.js";
export default defineEventHandler(async (e) => {
  const query = getQuery(e);
  const path = query.path;
  const isMockProduction = Boolean(query.mockProductionEnv);
  delete query.path;
  let robotsHeader = null;
  let robotsContent = null;
  let robotsHint = null;
  const res = await $fetch.raw(withQuery(path, query)).catch(() => null);
  if (res) {
    const html = String(res._data);
    robotsHeader = res.headers.get("x-robots-tag") || null;
    const meta = extractRobotsMetaFromHtml(html);
    if (meta) {
      if (isMockProduction) {
        const productionHeader = res.headers.get("x-robots-production");
        if (productionHeader) {
          robotsHeader = productionHeader;
        }
        if (meta.productionContent) {
          robotsContent = meta.productionContent;
          robotsHint = meta.hint;
        }
      }
      if (!robotsContent && meta.content) {
        robotsContent = meta.content;
        robotsHint = meta.hint;
      }
    }
  }
  if (!robotsContent) {
    const robotConfig = getPathRobotConfig(e, {
      path,
      skipSiteIndexable: isMockProduction
    });
    robotsContent = robotConfig.rule;
    robotsHint = robotConfig.debug?.source || null;
    if (!robotsHeader) {
      robotsHeader = robotConfig.rule;
    }
  }
  const [source, line] = robotsHint ? robotsHint.split(",") : [null, null];
  return {
    rule: robotsContent,
    indexable: !(robotsContent?.includes("noindex") || robotsHeader?.includes("noindex")),
    crawlable: !(source === "/robots.txt"),
    path,
    debug: {
      source,
      line
    },
    robotsHeader,
    robotsContent
  };
});
