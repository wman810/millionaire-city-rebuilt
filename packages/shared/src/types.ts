export type JsonPrimitive = string | number | boolean | null;
export type JsonValue = JsonPrimitive | JsonObject | JsonArray;
export interface JsonObject {
  [key: string]: JsonValue;
}
export interface JsonArray extends Array<JsonValue> {}

export interface LoginResponseData extends JsonObject {
  userId: number;
  userExtId: string;
  advisorId: string;
  token: string;
  currentServerTime: number;
}

export interface PacketCommand<T extends JsonObject = JsonObject> {
  _cmd: string;
  _dat: T;
  _cnt?: number;
  _sync?: number;
}

export interface ClientCommandList {
  _cmdList: PacketCommand[];
  _msgCount: number;
  _sync: number;
  retry?: number;
  ping?: number;
}

export interface ServerCommandList {
  list: PacketCommand[];
  _msgCount: number;
  _sync: number;
}

export interface GameEnvelopePayload<T extends JsonObject = JsonObject> {
  service: "Command";
  callId: string;
  responseCode: number;
  data: T;
}
