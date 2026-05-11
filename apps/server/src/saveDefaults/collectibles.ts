import type { JsonObject } from "@mcity/shared/dist/types.js";
import { createElement } from "../saveTree.js";

export function createEmptyCollectiblesDocument(): JsonObject {
  return createElement("collectiblesList", {}, [
    createElement("Objects", { skus: "" }),
    createElement("Rewards", { skus: "" }),
    createElement("Pending", { tupla: "" })
  ]);
}

export function createEmptyCollectiblePendingDocument(): JsonObject {
  return createElement("collectiblePendingList", {}, []);
}
