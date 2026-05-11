import type { JsonObject } from "@mcity/shared/dist/types.js";
import { cloneJsonValue, createElement, findElementChild } from "../saveTree.js";
import type { MutableNode } from "./universe.js";

const STATE_ATTRIBUTE_KEYS = ["mode", "time", "contractSku", "accelerated"] as const;

export function hasStateMutation(payload: Record<string, unknown>): boolean {
  return payload.state != null || STATE_ATTRIBUTE_KEYS.some((key) => payload[key] != null);
}

export function extractStateAttributes(payload: Record<string, unknown>): Record<string, string> {
  const attributes: Record<string, string> = {};
  if (payload.state != null) {
    attributes.id = String(payload.state);
  }

  for (const key of STATE_ATTRIBUTE_KEYS) {
    if (payload[key] != null) {
      attributes[key] = String(payload[key]);
    }
  }

  if (payload.time != null && Number(payload.time) > 0) {
    attributes.savedAt = String(Date.now());
  }

  return attributes;
}

export function extractIncomingItemEntry(value: unknown): MutableNode | undefined {
  if (!value || typeof value !== "object") {
    return undefined;
  }

  const entry = cloneJsonValue(value as MutableNode);
  if (!Array.isArray(entry.Item)) {
    return undefined;
  }

  return entry;
}

export function extractIncomingElement(value: unknown, tagName: string): MutableNode | undefined {
  if (!value || typeof value !== "object") {
    return undefined;
  }

  const entry = cloneJsonValue(value as MutableNode);
  if (!Array.isArray(entry[tagName])) {
    return undefined;
  }

  return entry;
}

export function parseCountChunkSet(entry: MutableNode | undefined): Map<string, number> {
  const counts = new Map<string, number>();
  if (!entry || typeof entry.chunk !== "string" || entry.chunk.length === 0) {
    return counts;
  }

  for (const part of entry.chunk.split(",")) {
    if (part.length === 0) {
      continue;
    }
    const separator = part.lastIndexOf("/");
    if (separator === -1) {
      continue;
    }
    const sku = part.slice(0, separator);
    const value = Number(part.slice(separator + 1));
    if (sku.length > 0 && Number.isFinite(value)) {
      counts.set(sku, value);
    }
  }

  return counts;
}

export function upsertCountChunkElement(children: JsonObject[], tagName: string, values: Map<string, number>): void {
  const existing = findElementChild(children, tagName);
  if (existing) {
    existing.chunk = serializeCountChunkSet(values);
    return;
  }

  children.push(createElement(tagName, { chunk: serializeCountChunkSet(values) }));
}

export function toRecord(value: unknown): Record<string, unknown> | undefined {
  return value && typeof value === "object" ? (value as Record<string, unknown>) : undefined;
}

function serializeCountChunkSet(values: Map<string, number>): string {
  return Array.from(values.entries())
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([sku, value]) => `${sku}/${value}`)
    .join(",");
}
