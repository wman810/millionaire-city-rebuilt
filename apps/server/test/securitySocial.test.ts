import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { afterEach, describe, expect, test } from "vitest";
import type { PacketCommand } from "@mcity/shared";
import type { JsonObject } from "@mcity/shared/dist/types.js";
import { getServerConfig, type ServerConfig } from "../src/config.js";
import { createServerApp } from "../src/serverApp.js";

type ServerApp = ReturnType<typeof createServerApp>;
type TestPacketCommand = PacketCommand<JsonObject> & { success?: string };

const activeApps: ServerApp[] = [];
const temporaryDirectories: string[] = [];

afterEach(async () => {
  while (activeApps.length > 0) {
    await activeApps.pop()?.stop();
  }
  while (temporaryDirectories.length > 0) {
    const directory = temporaryDirectories.pop();
    if (directory) {
      fs.rmSync(directory, { force: true, recursive: true });
    }
  }
});

describe("launcher authorization and archived social UI", () => {
  test("launch secret bootstrap creates a hardened cookie and redirects without exposing the token", async () => {
    const { config, launchSecret } = await startSecuredServer();
    const baseUrl = `http://127.0.0.1:${config.httpPort}`;

    const missingToken = await fetch(`${baseUrl}/launcher`, { redirect: "manual" });
    expect(missingToken.status).toBe(403);

    const wrongToken = await fetch(`${baseUrl}/launcher?launchToken=wrong`, { redirect: "manual" });
    expect(wrongToken.status).toBe(403);
    expect(wrongToken.headers.get("set-cookie")).toBeNull();

    const headerBootstrap = await fetch(`${baseUrl}/launcher?debug=1`, {
      headers: { "x-mcity-launch-token": launchSecret },
      redirect: "manual"
    });
    expect(headerBootstrap.status).toBe(200);
    expect(headerBootstrap.headers.get("set-cookie")).toMatch(/^mcity_launch_session=[a-f0-9]{64};/);
    expect(await headerBootstrap.text()).not.toContain(launchSecret);

    const bootstrap = await fetch(
      `${baseUrl}/launcher?debug=1&launchToken=${encodeURIComponent(launchSecret)}`,
      { redirect: "manual" }
    );
    expect(bootstrap.status).toBe(303);
    expect(bootstrap.headers.get("location")).toBe("/launcher?debug=1");
    expect(bootstrap.headers.get("location")).not.toContain(launchSecret);

    const setCookie = bootstrap.headers.get("set-cookie") ?? "";
    expect(setCookie).toMatch(/^mcity_launch_session=[a-f0-9]{64};/);
    expect(setCookie).toContain("Path=/");
    expect(setCookie).toContain("HttpOnly");
    expect(setCookie).toContain("Secure");
    expect(setCookie).toContain("SameSite=Strict");

    const cookie = cookiePair(setCookie);
    const launcher = await fetch(`${baseUrl}/launcher?debug=1`, {
      headers: { cookie }
    });
    expect(launcher.status).toBe(200);
    expect(await launcher.text()).toContain("<title>Millionaire City</title>");

  });

  test("local state and game protocol routes reject requests without a launcher session", async () => {
    const { config } = await startSecuredServer();
    const baseUrl = `http://127.0.0.1:${config.httpPort}`;

    const localRead = await fetch(`${baseUrl}/local/profile`);
    expect(localRead.status).toBe(403);

    const localMutation = await fetch(`${baseUrl}/local/resources/adjust`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ resource: "gold", delta: 1000 })
    });
    expect(localMutation.status).toBe(403);

    const gameLogin = await postGame(config.httpPort, {
      uid: config.launcherUserId,
      cmd: "login",
      version: config.gameVersion,
      data: "{}",
      flash_version: "WIN 32,0,0,0"
    });
    expect(gameLogin.status).toBe(403);

    const neighborData = await fetch(`${baseUrl}/dollar/info?action=getNeighborAllInfo`);
    expect(neighborData.status).toBe(403);
  });

  test("uid, version, authorization, and signature failures cannot mutate payment state", async () => {
    const { config, cookie } = await startSecuredServerAndBootstrap();
    const before = await readResources(config.httpPort, cookie);

    const loginResponse = await postGame(
      config.httpPort,
      {
        uid: config.launcherUserId,
        cmd: "login",
        version: config.gameVersion,
        data: "{}",
        flash_version: "WIN 32,0,0,0"
      },
      cookie
    );
    expect(loginResponse.status).toBe(200);
    const token = String(extractCommands(await loginResponse.text())[0]._dat.token);

    const paymentData = JSON.stringify({ type: "gold", sku: "0", price: 2000, _msgCount: 7 });
    const validPaymentRequest = {
      uid: config.launcherUserId,
      cmd: "payments",
      version: config.gameVersion,
      data: paymentData,
      flash_version: "WIN 32,0,0,0"
    };

    const withoutLauncherCookie = await postGame(config.httpPort, {
      ...validPaymentRequest,
      sig: signPayload(validPaymentRequest, token)
    });
    expect(withoutLauncherCookie.status).toBe(403);

    const wrongUidRequest = { ...validPaymentRequest, uid: "999999999999999" };
    const wrongUid = await postGame(
      config.httpPort,
      { ...wrongUidRequest, sig: signPayload(wrongUidRequest, token) },
      cookie
    );
    expect(wrongUid.status).toBe(403);
    expect(extractCommands(await wrongUid.text())[0]._dat.reason).toBe("uid");

    const wrongVersionRequest = { ...validPaymentRequest, version: "0.338" };
    const wrongVersion = await postGame(
      config.httpPort,
      { ...wrongVersionRequest, sig: signPayload(wrongVersionRequest, token) },
      cookie
    );
    expect(wrongVersion.status).toBe(403);
    expect(extractCommands(await wrongVersion.text())[0]._dat.reason).toBe("version");

    const badSignature = await postGame(
      config.httpPort,
      { ...validPaymentRequest, sig: "pass" },
      cookie
    );
    expect(badSignature.status).toBe(403);
    expect(extractCommands(await badSignature.text())[0]._dat.reason).toBe("signature");

    const afterRejectedRequests = await readResources(config.httpPort, cookie);
    expect(afterRejectedRequests.gold).toBe(before.gold);
    expect(afterRejectedRequests.paidGold).toBe(before.paidGold);

    const acceptedPayment = await postGame(
      config.httpPort,
      { ...validPaymentRequest, sig: signPayload(validPaymentRequest, token) },
      cookie
    );
    expect(acceptedPayment.status).toBe(200);
    const paymentCommands = extractCommands(await acceptedPayment.text());
    expect(paymentCommands).toHaveLength(1);
    expect(paymentCommands[0]._cmd).toBe("payments");
    expect(paymentCommands[0].success).toBe("1");
    expect(paymentCommands[0]._dat.success).toBeUndefined();
    expect(paymentCommands[0]._dat.awardedGold).toBe("1300");

    const afterAcceptedPayment = await readResources(config.httpPort, cookie);
    expect(afterAcceptedPayment.gold).toBe(before.gold + 1300);
    expect(afterAcceptedPayment.paidGold).toBe(before.paidGold + 1000);
  });

  test("serves the archived social renderer, exact empty host containers, and two NPC neighbors", async () => {
    const { config, cookie } = await startSecuredServerAndBootstrap();
    const baseUrl = `http://127.0.0.1:${config.httpPort}`;

    const neighborResponse = await fetch(`${baseUrl}/dollar/info?action=getNeighborAllInfo`, {
      headers: { cookie }
    });
    expect(neighborResponse.status).toBe(200);
    expect(await neighborResponse.json()).toEqual({
      neighbors: [
        { non_neighbors: [] },
        { pending: [] },
        { neighbors: [100, 101] }
      ]
    });

    const archivedRenderer = fs.readFileSync(
      path.join(config.launcherAssetRoot, "Datas", "js", "SocialWall.js"),
      "utf8"
    );
    const rendererResponse = await fetch(`${baseUrl}/local/social-wall.js`, {
      headers: { cookie }
    });
    expect(rendererResponse.status).toBe(200);
    const servedRenderer = await rendererResponse.text();
    expect(servedRenderer).toBe(
      archivedRenderer.replaceAll("https://graph.facebook.com/", "/local/social-picture/")
    );
    expect(servedRenderer).toContain("function DC_SocialWall(");
    expect(servedRenderer).toContain("function DC_Neighbors(");
    expect(servedRenderer).not.toContain("https://graph.facebook.com/");

    for (const npcId of ["100", "101"]) {
      const picture = await fetch(`${baseUrl}/local/social-picture/${npcId}/picture`, {
        headers: { cookie }
      });
      expect(picture.status).toBe(200);
      expect(picture.headers.get("content-type")).toContain("image/png");
      expect((await picture.arrayBuffer()).byteLength).toBeGreaterThan(0);
    }

    const launcherResponse = await fetch(`${baseUrl}/launcher`, {
      headers: { cookie }
    });
    expect(launcherResponse.status).toBe(200);
    const launcherHtml = await launcherResponse.text();
    expect(launcherHtml).toContain(`/local/jquery.min.js`);
    expect(launcherHtml).toContain(`/local/social-wall.js`);
    expect(launcherHtml).toMatch(
      /new\s+(?:window\.)?DC_SocialWall\(\s*["']dcsw["']\s*,\s*["']dcsw_requests_counter["']/
    );
    expect(launcherHtml).toMatch(/new\s+(?:window\.)?DC_Neighbors\(\s*["']neighbors["']/);
    expect(launcherHtml).toMatch(
      /<div id="neighbors" class="tab-content rounded-shadow"><\/div>/
    );
    expect(launcherHtml).toMatch(
      /<div id="dcsw" class="tab-content rounded-shadow"><\/div>/
    );
    expect(launcherHtml).not.toContain("Offline mode:");
    expect(launcherHtml).not.toContain("Facebook social features are disabled");
    expect(launcherHtml).not.toContain("Private server: Facebook features are disabled");
  });
});

async function startSecuredServer(): Promise<{
  app: ServerApp;
  config: ServerConfig;
  launchSecret: string;
}> {
  const temporaryDirectory = fs.mkdtempSync(path.join(os.tmpdir(), "mcity-security-social-"));
  temporaryDirectories.push(temporaryDirectory);
  const launchSecret = "focused-security-social-test-secret";
  const config: ServerConfig = {
    ...getServerConfig(),
    dbPath: path.join(temporaryDirectory, "save.sqlite"),
    httpPort: 0,
    httpsPort: 0,
    useHttpsFacebookShim: false,
    launchSecret
  };
  const app = createServerApp(config);
  activeApps.push(app);
  await app.start();
  return { app, config, launchSecret };
}

async function startSecuredServerAndBootstrap(): Promise<{
  app: ServerApp;
  config: ServerConfig;
  cookie: string;
}> {
  const { app, config, launchSecret } = await startSecuredServer();
  const response = await fetch(
    `http://127.0.0.1:${config.httpPort}/launcher?launchToken=${encodeURIComponent(launchSecret)}`,
    { redirect: "manual" }
  );
  expect(response.status).toBe(303);
  return {
    app,
    config,
    cookie: cookiePair(response.headers.get("set-cookie") ?? "")
  };
}

function cookiePair(setCookie: string): string {
  const pair = setCookie.split(";", 1)[0] ?? "";
  if (!pair.startsWith("mcity_launch_session=")) {
    throw new Error(`Launcher did not return a launch session cookie: ${setCookie}`);
  }
  return pair;
}

async function postGame(
  port: number,
  form: Record<string, string>,
  cookie?: string
): Promise<Response> {
  const headers: Record<string, string> = {
    "content-type": "application/x-www-form-urlencoded"
  };
  if (cookie) {
    headers.cookie = cookie;
  }
  return await fetch(`http://127.0.0.1:${port}/Game`, {
    method: "POST",
    headers,
    body: new URLSearchParams(form)
  });
}

async function readResources(
  port: number,
  cookie: string
): Promise<{ gold: number; paidGold: number }> {
  const response = await fetch(`http://127.0.0.1:${port}/local/resources`, {
    headers: { cookie }
  });
  expect(response.status).toBe(200);
  return await response.json() as { gold: number; paidGold: number };
}

function extractCommands(xml: string): TestPacketCommand[] {
  const match =
    xml.match(/<commands><!\[CDATA\[(.*)\]\]><\/commands>/s) ??
    xml.match(/<commands>(.*)<\/commands>/s);
  if (!match) {
    throw new Error(`Could not extract command payload from response: ${xml}`);
  }
  const payload = JSON.parse(match[1]) as { list: TestPacketCommand[] };
  return payload.list;
}

function signPayload(payload: Record<string, string>, token: string): string {
  const serialized = Object.entries(payload)
    .sort(([left], [right]) => left.localeCompare(right, undefined, { sensitivity: "base" }))
    .map(([key, value]) => `${key}=${value}`)
    .join("&");
  return crypto.createHash("md5").update(`${serialized}${token}Host4h`).digest("hex");
}
