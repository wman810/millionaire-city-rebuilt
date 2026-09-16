import fs from "node:fs";
import path from "node:path";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import { DATA_ROOT } from "./paths.js";

export type NpcLayoutName = "advisor" | "sheik";

export interface NpcWorldLayout {
  profile: JsonObject;
  world: JsonObject;
}

interface ParsedXmlElement {
  name: string;
  attributes: Record<string, string>;
  children: ParsedXmlElement[];
}

const NPC_LAYOUT_FILES: Record<NpcLayoutName, string> = {
  advisor: "universeAdvisorCity.xml",
  sheik: "universeAdvisorCity1_AbuDabhi.xml"
};
const NPC_LAYOUT_ROOT = path.join(DATA_ROOT, "userData");
const layoutCache = new Map<NpcLayoutName, NpcWorldLayout>();

export function loadNpcWorldLayout(name: NpcLayoutName): NpcWorldLayout {
  const cached = layoutCache.get(name);
  if (cached) {
    return cached;
  }

  const xml = fs.readFileSync(path.join(NPC_LAYOUT_ROOT, NPC_LAYOUT_FILES[name]), "utf8");
  const universe = parseXml(xml);
  if (universe.name !== "Universe") {
    throw new Error(`NPC layout ${NPC_LAYOUT_FILES[name]} does not contain a Universe root`);
  }

  const profile = universe.children.find((child) => child.name === "Profile");
  const plots = profile?.children.find((child) => child.name === "Plots");
  const world = universe.children.find((child) => child.name === "World");
  if (!profile || !plots || !world) {
    throw new Error(`NPC layout ${NPC_LAYOUT_FILES[name]} is missing its Plots or World element`);
  }

  const layout = {
    profile: toSaveTreeEntry(profile),
    world: toSaveTreeEntry(world)
  };
  layoutCache.set(name, layout);
  return layout;
}

function parseXml(xml: string): ParsedXmlElement {
  const roots: ParsedXmlElement[] = [];
  const stack: ParsedXmlElement[] = [];

  for (const match of xml.matchAll(/<([^<>]+)>/g)) {
    const token = (match[1] ?? "").trim();
    if (token.length === 0 || token.startsWith("?") || token.startsWith("!")) {
      continue;
    }

    if (token.startsWith("/")) {
      const closingName = token.slice(1).trim();
      const current = stack.pop();
      if (!current || current.name !== closingName) {
        throw new Error(`Malformed NPC layout XML near </${closingName}>`);
      }
      continue;
    }

    const selfClosing = token.endsWith("/");
    const opening = selfClosing ? token.slice(0, -1).trim() : token;
    const separator = opening.search(/\s/);
    const name = separator === -1 ? opening : opening.slice(0, separator);
    const attributeText = separator === -1 ? "" : opening.slice(separator + 1);
    const element: ParsedXmlElement = {
      name,
      attributes: parseAttributes(attributeText),
      children: []
    };

    const parent = stack[stack.length - 1];
    if (parent) {
      parent.children.push(element);
    } else {
      roots.push(element);
    }

    if (!selfClosing) {
      stack.push(element);
    }
  }

  if (stack.length !== 0 || roots.length !== 1) {
    throw new Error("Malformed NPC layout XML");
  }

  return roots[0];
}

function parseAttributes(value: string): Record<string, string> {
  const attributes: Record<string, string> = {};
  for (const match of value.matchAll(/([^\s=]+)\s*=\s*(?:"([^"]*)"|'([^']*)')/g)) {
    attributes[match[1]] = decodeXmlEntities(match[2] ?? match[3] ?? "");
  }
  return attributes;
}

function decodeXmlEntities(value: string): string {
  return value
    .replace(/&quot;/g, '"')
    .replace(/&apos;/g, "'")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&amp;/g, "&");
}

function toSaveTreeEntry(element: ParsedXmlElement): JsonObject {
  return {
    [element.name]: element.children.map(toSaveTreeEntry),
    ...element.attributes
  };
}
