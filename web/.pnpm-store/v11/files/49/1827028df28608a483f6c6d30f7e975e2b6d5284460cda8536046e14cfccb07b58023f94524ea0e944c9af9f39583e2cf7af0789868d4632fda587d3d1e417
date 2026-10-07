import { LocaleObject, NuxtI18nOptions } from '@nuxtjs/i18n';

declare const I18N_MODULES: readonly ["@nuxtjs/i18n", "nuxt-i18n-micro"];
type I18nModuleName = typeof I18N_MODULES[number];
type Strategies = 'no_prefix' | 'prefix_except_default' | 'prefix' | 'prefix_and_default';
type NormalisedLocale = LocaleObject & {
    _sitemap: string;
    _hreflang: string;
};
interface AutoI18nConfig {
    locales: NormalisedLocale[];
    defaultLocale: string;
    strategy: Strategies;
    differentDomains?: boolean;
    pages?: Record<string, Record<string, string | false>>;
}
interface StrategyProps {
    localeCode: string;
    pageLocales: string;
    nuxtI18nConfig: NuxtI18nOptions;
    forcedStrategy?: Strategies;
    normalisedLocales: AutoI18nConfig['locales'];
}
declare function generatePathForI18nPages(ctx: StrategyProps): string;
declare function splitPathForI18nLocales(path: string, autoI18n: AutoI18nConfig): string | string[];
interface ExpandedLocaleRoute {
    locale: string;
    path: string;
}
/**
 * Detect a compacted i18n route such as `/:locale(en|fr)/about`.
 *
 * Both `nuxt-i18n-micro` and `@nuxtjs/i18n` (experimental `compactRoutes`) collapse
 * per-locale routes into a single regex route using this syntax, so route-table
 * consumers (sitemap, link-checker) see one `:locale(...)` route instead of one per
 * locale.
 */
declare function isCompactLocaleRoute(path: string): boolean;
/**
 * Expand a compacted i18n route into one entry per locale.
 *
 * `/:locale(en|fr)/about` -> `[{ locale: 'en', path: '/en/about' }, { locale: 'fr', path: '/fr/about' }]`
 *
 * Pass `knownLocales` to guard against a genuine `:locale` route param: when provided,
 * expansion only runs if at least one captured token is a real locale code. Returns
 * `null` when the path is not a compacted locale route.
 */
declare function expandCompactLocaleRoute(path: string, knownLocales?: string[]): ExpandedLocaleRoute[] | null;
declare function normalizeLocales(nuxtI18nConfig: NuxtI18nOptions): AutoI18nConfig['locales'];
declare function mapPathForI18nPages(path: string, autoI18n: AutoI18nConfig): string[] | false;
interface I18nModuleResolution {
    module: I18nModuleName;
    isMicro: boolean;
}
/**
 * Detect which i18n module is installed (@nuxtjs/i18n or nuxt-i18n-micro).
 *
 * Returns `false` when neither is installed.
 */
declare function resolveI18nModule(): false | I18nModuleResolution;
declare function resolveI18nConfig(logger?: {
    warn: (msg: string) => void;
}): Promise<false | AutoI18nConfig>;
declare function mergeOnKey<T extends Record<string, any>>(arr: T[], key: keyof T): T[];

export { expandCompactLocaleRoute, generatePathForI18nPages, isCompactLocaleRoute, mapPathForI18nPages, mergeOnKey, normalizeLocales, resolveI18nConfig, resolveI18nModule, splitPathForI18nLocales };
export type { AutoI18nConfig, ExpandedLocaleRoute, I18nModuleResolution, NormalisedLocale, Strategies, StrategyProps };
