import https from "https";
import express from "express";
import selfsigned from "selfsigned";

export interface FacebookShimPicture {
  filePath: string;
  mimeType: string;
}

interface FacebookShimOptions {
  port: number;
  currentUserId: string;
  getCurrentUserName: () => string;
  getCurrentUserPicture?: () => FacebookShimPicture | undefined;
}

export interface FacebookShimHandle {
  server: https.Server;
  url: string;
}

export async function startFacebookShim(options: FacebookShimOptions): Promise<FacebookShimHandle> {
  const app = express();
  const transparentGif = Buffer.from(
    "R0lGODlhAQABAIABAP///wAAACwAAAAAAQABAAACAkQBADs=",
    "base64"
  );

  app.use((req, _res, next) => {
    console.log(`[fbshim] ${req.method} ${req.originalUrl}`);
    next();
  });

  app.get("/crossdomain.xml", (_req, res) => {
    res.type("application/xml").send(`<!DOCTYPE cross-domain-policy SYSTEM "http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd">
<cross-domain-policy>
  <site-control permitted-cross-domain-policies="all" />
  <allow-access-from domain="*" secure="true" />
</cross-domain-policy>`);
  });

  app.get("/me/friends", (_req, res) => {
    res.json({
      data: []
    });
  });

  app.get("/method/friends.getAppUsers", (_req, res) => {
    res.json([]);
  });

  app.get("/method/users.getInfo", (req, res) => {
    const uids = String(req.query.uids ?? "")
      .split(",")
      .map((uid) => uid.trim())
      .filter(Boolean);

    res.json(
      uids.map((uid, index) => ({
        uid,
        first_name: uid === options.currentUserId ? options.getCurrentUserName() : `Friend ${index + 1}`,
        last_name: "",
        pic_square: uid === options.currentUserId
          ? `https://graph.facebook.com/${options.currentUserId}/picture`
          : "https://graph.facebook.com/100/picture",
        locale: "en_US"
      }))
    );
  });

  app.get("/method/pages.isFan", (_req, res) => {
    res.json(true);
  });

  app.get("/:id/picture", (req, res) => {
    if (req.params.id === options.currentUserId) {
      const picture = options.getCurrentUserPicture?.();
      if (picture) {
        res.type(picture.mimeType);
        res.sendFile(picture.filePath);
        return;
      }
    }

    res.setHeader("content-type", "image/gif");
    res.send(transparentGif);
  });

  const pems = selfsigned.generate(
    [
      { name: "commonName", value: "graph.facebook.com" },
      { name: "organizationName", value: "Millionaire City Revival" }
    ],
    {
      days: 3650,
      keySize: 2048,
      algorithm: "sha256",
      extensions: [
        {
          name: "subjectAltName",
          altNames: [
            { type: 2, value: "graph.facebook.com" },
            { type: 2, value: "api.facebook.com" }
          ]
        }
      ]
    }
  );

  const server = https.createServer({ key: pems.private, cert: pems.cert }, app);

  await new Promise<void>((resolve, reject) => {
    server.once("error", reject);
    server.listen(options.port, "0.0.0.0", () => resolve());
  });

  return {
    server,
    url: `https://127.0.0.1:${options.port}`
  };
}
