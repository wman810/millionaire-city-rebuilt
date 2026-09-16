const crypto = require("node:crypto");
const fs = require("node:fs");
const path = require("node:path");

const sourceRoot = process.argv[2];
if (!sourceRoot) {
  throw new Error("Usage: node scripts/importNpcCityLayouts.cjs <old-cdn-root>");
}

const targetRoot = path.resolve(
  __dirname,
  "../assets/dchoc1-a.akamaihd.net/0.501/mcity/Datas/userData"
);
const fixtures = [
  {
    name: "universeAdvisorCity.xml",
    sha256: "efcaf73835e3d4a71e0e4940fd3592b11527d9676f4df0036c7ed5e4eeab2c5f"
  },
  {
    name: "universeAdvisorCity1_AbuDabhi.xml",
    sha256: "e857a0e9acf6e9bfdc2864cb5fa305025bdf718a0f0a0e6d98b37260ec4ea077"
  }
];

fs.mkdirSync(targetRoot, { recursive: true });

for (const fixture of fixtures) {
  const sourcePath = path.join(sourceRoot, "cdn", "userData", fixture.name);
  const targetPath = path.join(targetRoot, fixture.name);
  const contents = fs.readFileSync(sourcePath);
  const digest = crypto.createHash("sha256").update(contents).digest("hex");

  if (digest !== fixture.sha256) {
    throw new Error(`${fixture.name} does not match the recovered CDN fixture (${digest})`);
  }

  fs.writeFileSync(targetPath, contents);
  console.log(`Imported ${fixture.name} (${contents.length} bytes, ${digest})`);
}
