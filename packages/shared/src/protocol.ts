import { DEFAULT_SYNC } from "./constants.js";
import type { ClientCommandList, GameEnvelopePayload, JsonObject, PacketCommand, ServerCommandList } from "./types.js";

export function buildLoginEnvelope(command: PacketCommand, callId = "login"): string {
  const commands = JSON.stringify({
    list: [command],
    _msgCount: -1,
    _sync: command._sync ?? DEFAULT_SYNC
  });
  return buildEnvelope({
    service: "Command",
    callId,
    responseCode: 0,
    data: {
      chk: getChk(commands),
      commands
    }
  });
}

export function buildCommandEnvelope(commands: PacketCommand[], msgCount: number, sync = DEFAULT_SYNC): string {
  const payload: ServerCommandList = {
    list: commands,
    _msgCount: msgCount,
    _sync: sync
  };
  const serializedCommands = JSON.stringify(payload);

  return buildEnvelope({
    service: "Command",
    callId: "cmdList",
    responseCode: 0,
    data: {
      chk: getChk(serializedCommands),
      commands: serializedCommands
    }
  });
}

function buildEnvelope(payload: GameEnvelopePayload<{ chk: number; commands: string }>): string {
  return [
    `<Response service="${payload.service}" call_id="${payload.callId}">`,
    `  <response_code>${payload.responseCode}</response_code>`,
    "  <data>",
    `    <chk>${payload.data.chk}</chk>`,
    `    <commands><![CDATA[${payload.data.commands}]]></commands>`,
    "  </data>",
    "</Response>"
  ].join("\n");
}

export function normalizeIncomingCommandList(raw: unknown): PacketCommand<JsonObject>[] {
  if (!isClientCommandList(raw)) {
    return [];
  }

  return raw._cmdList.filter(isPacketCommand);
}

function getChk(value: string): number {
  let checksum = 317;

  for (let index = 0; index < value.length; index += 1) {
    checksum = (23 * checksum + value.charCodeAt(index)) | 0;
  }

  return checksum;
}

function isClientCommandList(value: unknown): value is ClientCommandList {
  return Boolean(
    value &&
      typeof value === "object" &&
      Array.isArray((value as { _cmdList?: unknown })._cmdList)
  );
}

function isPacketCommand(value: unknown): value is PacketCommand<JsonObject> {
  return Boolean(value && typeof value === "object" && typeof (value as { _cmd?: unknown })._cmd === "string");
}
