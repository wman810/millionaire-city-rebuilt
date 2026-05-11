import type { JsonObject } from "@mcity/shared/dist/types.js";

export function leafElement(name: string, attributes: Record<string, string>): JsonObject {
  return {
    [name]: [],
    ...attributes
  };
}

export function createElement(name: string, attributes: Record<string, string>, children: JsonObject[] = []): JsonObject {
  return {
    [name]: children,
    ...attributes
  };
}

export function getElementChildren(entry: JsonObject, tagName: string): JsonObject[] {
  const current = entry[tagName];
  if (Array.isArray(current)) {
    return current as JsonObject[];
  }

  const children: JsonObject[] = [];
  entry[tagName] = children;
  return children;
}

export function findElementChild(children: JsonObject[], tagName: string): JsonObject | undefined {
  return children.find(
    (entry): entry is JsonObject =>
      Boolean(entry && typeof entry === "object" && Array.isArray((entry as Record<string, unknown>)[tagName]))
  );
}

export function getOrCreateElementChild(children: JsonObject[], tagName: string): JsonObject {
  const existing = findElementChild(children, tagName);
  if (existing) {
    return existing;
  }

  const entry = createElement(tagName, {});
  children.push(entry);
  return entry;
}

export function upsertElementChild(children: JsonObject[], tagName: string, entry: JsonObject): void {
  const existingIndex = children.findIndex(
    (child) => Boolean(child && typeof child === "object" && Array.isArray((child as Record<string, unknown>)[tagName]))
  );

  if (existingIndex === -1) {
    children.push(entry);
    return;
  }

  children[existingIndex] = entry;
}

export function cloneJsonValue<T>(value: T): T {
  return JSON.parse(JSON.stringify(value)) as T;
}

export function parseChunkSet(entry: JsonObject | undefined): Set<string> {
  if (!entry || typeof entry.chunk !== "string" || entry.chunk.length === 0) {
    return new Set<string>();
  }

  return new Set(entry.chunk.split(",").filter((part: string) => part.length > 0));
}

export function serializeChunkSet(values: Set<string>): string {
  return Array.from(values).sort().join(",");
}

export function upsertChunkElement(children: JsonObject[], tagName: string, values: Set<string>): void {
  const existing = findElementChild(children, tagName);
  if (existing) {
    existing.chunk = serializeChunkSet(values);
    return;
  }

  children.push(createElement(tagName, { chunk: serializeChunkSet(values) }));
}
