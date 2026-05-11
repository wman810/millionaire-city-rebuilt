import fs from "fs";
import path from "path";

import { getServerConfig } from "../config";
import { loadDefinitionAttributes } from "../rules";

type Confidence = "high" | "medium";

type MissingAsset = {
  category: string;
  source: string;
  reference: string;
  expectedPath: string;
  confidence: Confidence;
  note?: string;
};

type AssetReference = MissingAsset & {
  exists: boolean;
};

type UnmappedReference = {
  source: string;
  attribute: string;
  reference: string;
};

const MEDIA_REFERENCE_PATTERN = /([A-Za-z0-9_:-]+)="([^"]+\.(?:swf|png|jpg|jpeg|gif|mp3|wav))"/g;
const REPORT_DIRECTORY = ["generated", "reports"];

function normalizeRelativePath(relativePath: string): string {
  let normalized = relativePath.replace(/\\/g, "/").replace(/^\.\/+/, "").replace(/^\/+/, "");
  if (normalized.startsWith("Datas/")) {
    normalized = normalized.slice("Datas/".length);
  }
  return normalized;
}

function toDisplayPath(relativePath: string): string {
  return normalizeRelativePath(relativePath).replace(/\//g, "/");
}

function collectFiles(rootPath: string, extension: string): string[] {
  if (!fs.existsSync(rootPath)) {
    return [];
  }

  const results: string[] = [];
  const stack = [rootPath];
  while (stack.length > 0) {
    const currentPath = stack.pop();
    if (!currentPath) {
      continue;
    }

    for (const entry of fs.readdirSync(currentPath, { withFileTypes: true })) {
      const entryPath = path.join(currentPath, entry.name);
      if (entry.isDirectory()) {
        stack.push(entryPath);
      } else if (entry.isFile() && entry.name.toLowerCase().endsWith(extension)) {
        results.push(entryPath);
      }
    }
  }

  return results;
}

function buildExistingAssetSet(dataRoot: string): Set<string> {
  const files = collectFiles(dataRoot, "");
  return new Set(
    files.map((filePath) => normalizeRelativePath(path.relative(dataRoot, filePath)).toLowerCase())
  );
}

function hasAsset(existingAssets: Set<string>, relativePath: string): boolean {
  return existingAssets.has(normalizeRelativePath(relativePath).toLowerCase());
}

function addResolvedAsset(target: AssetReference[], seen: Set<string>, asset: AssetReference): void {
  const key = [
    asset.category,
    asset.source,
    asset.reference,
    asset.expectedPath,
    asset.confidence,
    asset.note ?? ""
  ].join("|");
  if (seen.has(key)) {
    return;
  }

  seen.add(key);
  target.push(asset);
}

function addMissingAsset(target: MissingAsset[], seen: Set<string>, asset: MissingAsset): void {
  const key = [
    asset.category,
    asset.source,
    asset.reference,
    asset.expectedPath,
    asset.confidence,
    asset.note ?? ""
  ].join("|");
  if (seen.has(key)) {
    return;
  }

  seen.add(key);
  target.push(asset);
}

function resolveExplicitAssetPath(xmlName: string, attributeName: string, value: string): string | null {
  if (value.includes("://")) {
    return null;
  }

  if (/[\\/]/.test(value)) {
    return normalizeRelativePath(value);
  }

  if (attributeName === "feedImg") {
    return `feed/${value}`;
  }

  if (xmlName === "NPCDefinitions.xml" && attributeName === "url") {
    return `Assets/missions/icons/${value}`;
  }

  if (attributeName === "music" || attributeName === "sound" || attributeName === "musicFile" || attributeName === "soundFile") {
    return `sounds/${value}`;
  }

  return null;
}

function collectExplicitXmlReferences(
  dataRoot: string,
  existingAssets: Set<string>,
  resolvedAssets: AssetReference[],
  resolvedSeen: Set<string>,
  missingAssets: MissingAsset[],
  missingSeen: Set<string>,
  unmappedReferences: UnmappedReference[],
  unmappedSeen: Set<string>
): void {
  const xmlFiles = collectFiles(dataRoot, ".xml");
  for (const xmlPath of xmlFiles) {
    const xmlName = path.basename(xmlPath);
    const xmlRelativePath = toDisplayPath(path.relative(dataRoot, xmlPath));
    const xml = fs.readFileSync(xmlPath, "utf8");

    for (const match of xml.matchAll(MEDIA_REFERENCE_PATTERN)) {
      const attributeName = match[1] ?? "";
      const reference = match[2] ?? "";
      const expectedPath = resolveExplicitAssetPath(xmlName, attributeName, reference);

      if (!expectedPath) {
        const unmappedKey = [xmlRelativePath, attributeName, reference].join("|");
        if (!unmappedSeen.has(unmappedKey)) {
          unmappedSeen.add(unmappedKey);
          unmappedReferences.push({
            source: xmlRelativePath,
            attribute: attributeName,
            reference
          });
        }
        continue;
      }

      const exists = hasAsset(existingAssets, expectedPath);
      addResolvedAsset(resolvedAssets, resolvedSeen, {
        category: "Explicit XML reference",
        source: xmlRelativePath,
        reference,
        expectedPath: toDisplayPath(expectedPath),
        confidence: "high",
        note: `${attributeName} in ${xmlName}`,
        exists
      });

      if (!hasAsset(existingAssets, expectedPath)) {
        addMissingAsset(missingAssets, missingSeen, {
          category: "Explicit XML reference",
          source: xmlRelativePath,
          reference,
          expectedPath: toDisplayPath(expectedPath),
          confidence: "high",
          note: `${attributeName} in ${xmlName}`
        });
      }
    }
  }
}

function collectSkuBackedAssets(
  dataRoot: string,
  existingAssets: Set<string>,
  resolvedAssets: AssetReference[],
  resolvedSeen: Set<string>,
  missingAssets: MissingAsset[],
  missingSeen: Set<string>
): void {
  const rulesRoot = path.join(dataRoot, "rules");
  const skuDefinitionFiles = [
    "itemDefinitions.xml",
    "commerceDefinitions.xml",
    "decorationDefinitions.xml",
    "wonderDefinitions.xml"
  ];

  for (const definitionFile of skuDefinitionFiles) {
    const definitionPath = path.join(rulesRoot, definitionFile);
    const source = `rules/${definitionFile}`;
    for (const definition of loadDefinitionAttributes(definitionPath)) {
      const sku = definition.sku?.trim();
      if (!sku) {
        continue;
      }

      const expectedSwf = `Assets/items/${sku}.swf`;
      const exists = hasAsset(existingAssets, expectedSwf);
      addResolvedAsset(resolvedAssets, resolvedSeen, {
        category: "Definition-backed item SWF",
        source,
        reference: sku,
        expectedPath: toDisplayPath(expectedSwf),
        confidence: "high",
        exists
      });
      if (!exists) {
        addMissingAsset(missingAssets, missingSeen, {
          category: "Definition-backed item SWF",
          source,
          reference: sku,
          expectedPath: toDisplayPath(expectedSwf),
          confidence: "high"
        });
      }
    }
  }

  for (const definition of loadDefinitionAttributes(path.join(rulesRoot, "commerceDefinitions.xml"))) {
    const sku = definition.sku?.trim();
    if (!sku) {
      continue;
    }

    const expectedIcon = `Assets/items/CommerceTypes/icons/${sku}.png`;
    const exists = hasAsset(existingAssets, expectedIcon);
    addResolvedAsset(resolvedAssets, resolvedSeen, {
      category: "Commerce icon",
      source: "rules/commerceDefinitions.xml",
      reference: sku,
      expectedPath: toDisplayPath(expectedIcon),
      confidence: "medium",
      note: "Loaded via ItemDefinition.getCommerceIcon()",
      exists
    });
    if (!exists) {
      addMissingAsset(missingAssets, missingSeen, {
        category: "Commerce icon",
        source: "rules/commerceDefinitions.xml",
        reference: sku,
        expectedPath: toDisplayPath(expectedIcon),
        confidence: "medium",
        note: "Loaded via ItemDefinition.getCommerceIcon()"
      });
    }
  }

  const missionTypes = new Set<string>();
  for (const definition of loadDefinitionAttributes(path.join(rulesRoot, "missionDefinitions.xml"))) {
    const missionType = definition.type?.trim();
    if (missionType) {
      missionTypes.add(missionType);
    }
  }

  for (const missionType of [...missionTypes].sort()) {
    const expectedIcon = `Assets/missions/icons/${missionType}.png`;
    const exists = hasAsset(existingAssets, expectedIcon);
    addResolvedAsset(resolvedAssets, resolvedSeen, {
      category: "Mission icon",
      source: "rules/missionDefinitions.xml",
      reference: missionType,
      expectedPath: toDisplayPath(expectedIcon),
      confidence: "medium",
      exists
    });
    if (!exists) {
      addMissingAsset(missingAssets, missingSeen, {
        category: "Mission icon",
        source: "rules/missionDefinitions.xml",
        reference: missionType,
        expectedPath: toDisplayPath(expectedIcon),
        confidence: "medium"
      });
    }
  }
}

function countExistingMediaFiles(dataRoot: string): number {
  const mediaExtensions = new Set([".swf", ".png", ".jpg", ".jpeg", ".gif", ".mp3", ".wav"]);
  const results = collectFiles(dataRoot, "");
  return results.filter((filePath) => mediaExtensions.has(path.extname(filePath).toLowerCase())).length;
}

function classifyPlayability(asset: MissingAsset): string {
  if (asset.expectedPath.startsWith("Assets/items/") && !asset.expectedPath.includes("/CommerceTypes/icons/")) {
    return "Critical gameplay assets";
  }
  if (asset.expectedPath.startsWith("Assets/missions/icons/")) {
    return "Gameplay UI assets";
  }
  if (asset.expectedPath.startsWith("Assets/items/CommerceTypes/icons/")) {
    return "Helpful UI assets";
  }
  if (asset.expectedPath.startsWith("feed/")) {
    return "Low-priority cosmetic assets";
  }
  return "Other assets";
}

type CoverageSummary = {
  existingMediaFiles: number;
  uniqueExpectedAssets: number;
  uniqueExistingExpectedAssets: number;
  uniqueMissingExpectedAssets: number;
  coveragePercent: number;
};

function buildCoverageSummary(resolvedAssets: AssetReference[], dataRoot: string): CoverageSummary {
  const uniqueExpectedAssets = new Map<string, boolean>();
  for (const asset of resolvedAssets) {
    const existingValue = uniqueExpectedAssets.get(asset.expectedPath);
    uniqueExpectedAssets.set(asset.expectedPath, existingValue === true || asset.exists);
  }

  const uniqueExpectedCount = uniqueExpectedAssets.size;
  const uniqueExistingCount = [...uniqueExpectedAssets.values()].filter(Boolean).length;
  const uniqueMissingCount = uniqueExpectedCount - uniqueExistingCount;
  const coveragePercent = uniqueExpectedCount === 0 ? 100 : (uniqueExistingCount / uniqueExpectedCount) * 100;

  return {
    existingMediaFiles: countExistingMediaFiles(dataRoot),
    uniqueExpectedAssets: uniqueExpectedCount,
    uniqueExistingExpectedAssets: uniqueExistingCount,
    uniqueMissingExpectedAssets: uniqueMissingCount,
    coveragePercent
  };
}

function renderMarkdownReport(
  resolvedAssets: AssetReference[],
  missingAssets: MissingAsset[],
  unmappedReferences: UnmappedReference[],
  dataRoot: string
): string {
  const coverage = buildCoverageSummary(resolvedAssets, dataRoot);
  const grouped = new Map<string, MissingAsset[]>();
  for (const asset of missingAssets) {
    const group = grouped.get(asset.category) ?? [];
    group.push(asset);
    grouped.set(asset.category, group);
  }

  const playabilityGroups = new Map<string, MissingAsset[]>();
  for (const asset of missingAssets) {
    const playability = classifyPlayability(asset);
    const group = playabilityGroups.get(playability) ?? [];
    group.push(asset);
    playabilityGroups.set(playability, group);
  }

  let markdown = "# Missing Assets Report\n\n";
  markdown += `Archive root scanned: \`${toDisplayPath(dataRoot)}\`\n\n`;
  markdown += "## Summary\n\n";
  markdown += `- Missing assets found: \`${missingAssets.length}\`\n`;
  markdown += `- Unmapped XML media references: \`${unmappedReferences.length}\`\n\n`;
  markdown += "## Asset Coverage\n\n";
  markdown += `- Media asset files currently present in archive: \`${coverage.existingMediaFiles}\`\n`;
  markdown += `- Unique expected/referenced assets checked: \`${coverage.uniqueExpectedAssets}\`\n`;
  markdown += `- Unique expected/referenced assets present: \`${coverage.uniqueExistingExpectedAssets}\`\n`;
  markdown += `- Unique expected/referenced assets missing: \`${coverage.uniqueMissingExpectedAssets}\`\n`;
  markdown += `- Coverage: \`${coverage.coveragePercent.toFixed(1)}%\`\n\n`;
  markdown += "## Missing Assets By Playability\n\n";
  markdown += "| Group | Missing Count |\n";
  markdown += "| --- | --- |\n";
  for (const [group, assets] of [...playabilityGroups.entries()].sort((left, right) => right[1].length - left[1].length)) {
    markdown += `| ${group} | \`${assets.length}\` |\n`;
  }
  markdown += "\n";

  for (const [group, assets] of [...playabilityGroups.entries()].sort((left, right) => right[1].length - left[1].length)) {
    markdown += `### ${group}\n\n`;
    markdown += "| Expected Path | Source | Confidence |\n";
    markdown += "| --- | --- | --- |\n";
    for (const asset of assets
      .slice()
      .sort((left, right) => left.expectedPath.localeCompare(right.expectedPath))) {
      markdown += `| \`${asset.expectedPath}\` | \`${asset.source}\` | \`${asset.confidence}\` |\n`;
    }
    markdown += "\n";
  }

  for (const [category, assets] of [...grouped.entries()].sort(([left], [right]) => left.localeCompare(right))) {
    markdown += `## ${category}\n\n`;
    markdown += "| Source | Reference | Expected Path | Confidence | Note |\n";
    markdown += "| --- | --- | --- | --- | --- |\n";
    for (const asset of assets.sort((left, right) => {
      const sourceCompare = left.source.localeCompare(right.source);
      if (sourceCompare !== 0) {
        return sourceCompare;
      }
      return left.expectedPath.localeCompare(right.expectedPath);
    })) {
      markdown += `| \`${asset.source}\` | \`${asset.reference}\` | \`${asset.expectedPath}\` | \`${asset.confidence}\` | ${asset.note ?? ""} |\n`;
    }
    markdown += "\n";
  }

  if (unmappedReferences.length > 0) {
    markdown += "## Unmapped XML Media References\n\n";
    markdown += "| Source | Attribute | Reference |\n";
    markdown += "| --- | --- | --- |\n";
    for (const reference of unmappedReferences.sort((left, right) => {
      const sourceCompare = left.source.localeCompare(right.source);
      if (sourceCompare !== 0) {
        return sourceCompare;
      }
      const attributeCompare = left.attribute.localeCompare(right.attribute);
      if (attributeCompare !== 0) {
        return attributeCompare;
      }
      return left.reference.localeCompare(right.reference);
    })) {
      markdown += `| \`${reference.source}\` | \`${reference.attribute}\` | \`${reference.reference}\` |\n`;
    }
    markdown += "\n";
  }

  return markdown;
}

function main(): void {
  const config = getServerConfig();
  const dataRoot = path.join(config.assetRoot, "Datas");
  const existingAssets = buildExistingAssetSet(dataRoot);
  const resolvedAssets: AssetReference[] = [];
  const resolvedSeen = new Set<string>();
  const missingAssets: MissingAsset[] = [];
  const missingSeen = new Set<string>();
  const unmappedReferences: UnmappedReference[] = [];
  const unmappedSeen = new Set<string>();

  collectExplicitXmlReferences(dataRoot, existingAssets, resolvedAssets, resolvedSeen, missingAssets, missingSeen, unmappedReferences, unmappedSeen);
  collectSkuBackedAssets(dataRoot, existingAssets, resolvedAssets, resolvedSeen, missingAssets, missingSeen);

  const reportDirectory = path.join(config.workspaceRoot, ...REPORT_DIRECTORY);
  fs.mkdirSync(reportDirectory, { recursive: true });

  const reportJsonPath = path.join(reportDirectory, "missing-assets.json");
  const reportMarkdownPath = path.join(reportDirectory, "missing-assets.md");
  const coverageSummary = buildCoverageSummary(resolvedAssets, dataRoot);

  fs.writeFileSync(reportJsonPath, JSON.stringify({
    generatedAt: new Date().toISOString(),
    archiveRoot: dataRoot,
    coverageSummary,
    resolvedAssets,
    missingAssets,
    unmappedReferences
  }, null, 2));
  fs.writeFileSync(reportMarkdownPath, renderMarkdownReport(resolvedAssets, missingAssets, unmappedReferences, dataRoot));

  console.log(`Missing assets found: ${missingAssets.length}`);
  console.log(`Unmapped XML media references: ${unmappedReferences.length}`);
  console.log(`Coverage: ${coverageSummary.coveragePercent.toFixed(1)}% (${coverageSummary.uniqueExistingExpectedAssets}/${coverageSummary.uniqueExpectedAssets})`);
  console.log(`Markdown report: ${reportMarkdownPath}`);
  console.log(`JSON report: ${reportJsonPath}`);
}

main();
