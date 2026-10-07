import { d as defineSchemaOrgResolver } from './schema-org.Dryb3EoR.mjs';

const ratingResolver = defineSchemaOrgResolver({
  cast(node) {
    if (node === "number") {
      return {
        ratingValue: node
      };
    }
    return node;
  },
  defaults: {
    "@type": "Rating",
    "bestRating": 5,
    "worstRating": 1
  }
});

export { ratingResolver as r };
