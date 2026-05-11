import type { MutableNode } from "./universe.js";
import { getUniverseProfile } from "./universe.js";

export function decodeAsciiCodes(value: string): string {
  const parts = value.split(",").filter((part) => part.length > 0);
  if (parts.length === 0) {
    return "";
  }

  return parts
    .map((part) => Number.parseInt(part, 10))
    .filter((code) => Number.isFinite(code) && code > 0)
    .map((code) => String.fromCharCode(code))
    .join("");
}

export function encodeAsciiCodes(value: string): string {
  return Array.from(value)
    .map((character) => character.charCodeAt(0))
    .join(",");
}

export function sanitizeUniverseForClient<T>(value: T): T {
  if (!value || typeof value !== "object") {
    return sanitizeForClientXml(value);
  }

  const sanitized = sanitizeForClientXml(value) as T & { universe?: unknown };
  const profile = getUniverseProfile(sanitized as MutableNode);
  if (!profile) {
    return sanitized;
  }

  const normalizedName = sanitizeStoredString(
    decodeAsciiCodes(unescapeXmlAttributeValue(String(profile.cityNameCodes ?? "")))
  );
  if (normalizedName.length > 0) {
    profile.cityname = escapeXmlAttributeValue(normalizedName);
    profile.cityNameCodes = escapeXmlAttributeValue(encodeAsciiCodes(normalizedName));
  } else if (typeof profile.cityname === "string") {
    const fallbackName = sanitizeStoredString(unescapeXmlAttributeValue(String(profile.cityname)));
    profile.cityname = escapeXmlAttributeValue(fallbackName);
    profile.cityNameCodes = escapeXmlAttributeValue(encodeAsciiCodes(fallbackName));
  }

  if (typeof profile.userName === "string") {
    profile.userName = escapeXmlAttributeValue(sanitizeStoredString(unescapeXmlAttributeValue(profile.userName)));
  }

  return sanitized;
}

export function sanitizeForClientXml<T>(value: T): T {
  if (Array.isArray(value)) {
    return value.map((entry) => sanitizeForClientXml(entry)) as T;
  }

  if (value && typeof value === "object") {
    const result: Record<string, unknown> = {};
    for (const [key, entry] of Object.entries(value)) {
      result[key] = sanitizeForClientXml(entry);
    }
    return result as T;
  }

  if (typeof value === "string") {
    return escapeXmlAttributeValue(sanitizeStoredString(value)) as T;
  }

  return value;
}

export function sanitizeStoredString(value: string): string {
  return value.replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, "");
}

function escapeXmlAttributeValue(value: string): string {
  return value
    .replace(/&/g, "&amp;")
    .replace(/\"/g, "&quot;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/'/g, "&apos;");
}

function unescapeXmlAttributeValue(value: string): string {
  return value
    .replace(/&quot;/g, "\"")
    .replace(/&apos;/g, "'")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&amp;/g, "&");
}
