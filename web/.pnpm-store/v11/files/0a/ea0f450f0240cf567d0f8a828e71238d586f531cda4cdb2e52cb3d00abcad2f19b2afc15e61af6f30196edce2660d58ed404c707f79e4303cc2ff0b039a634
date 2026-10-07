import { d as defineSchemaOrgResolver, aa as resolveDefaultType, e as resolveRelation } from '../shared/schema-org.Dryb3EoR.mjs';
import { aggregateRatingResolver } from './index2.mjs';
import { offerResolver } from './index23.mjs';
import { reviewResolver } from './index32.mjs';
import 'unhead/plugins';
import 'unhead/utils';
import 'ufo';
import '../shared/schema-org.F44ipjVJ.mjs';
import './index3.mjs';
import './index16.mjs';
import './index28.mjs';
import './index40.mjs';
import './index39.mjs';
import '../shared/schema-org.Ba7D0Hp1.mjs';

const softwareAppResolver = defineSchemaOrgResolver({
  defaults: {
    "@type": "SoftwareApplication"
  },
  resolve(node, ctx) {
    resolveDefaultType(node, "SoftwareApplication");
    node.offers = resolveRelation(node.offers, ctx, offerResolver);
    node.aggregateRating = resolveRelation(node.aggregateRating, ctx, aggregateRatingResolver);
    node.review = resolveRelation(node.review, ctx, reviewResolver);
    return node;
  }
});

export { softwareAppResolver };
