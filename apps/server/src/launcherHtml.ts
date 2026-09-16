import { GAME_VERSION } from "@mcity/shared";

interface LauncherOptions {
  appUrl: string;
  assetsBaseUrl: string;
  gameAssetsBaseUrl?: string;
  gameVersion?: string;
  clientSwfUrl?: string;
  serverBaseUrl: string;
  userId: string;
  oauthToken: string;
  gameToken: string;
  facebookAppId: string;
  lang: string;
  debugMode: boolean;
  climateMode: boolean;
  oldItemDesigns: boolean;
  localUserName: string;
  localCityName: string;
  localProfilePictureUrl: string;
  advisorName?: string;
}

interface OriginalFreeGift {
  id: string;
  name: string;
  level: number;
  background: "fgift_openBox.png" | "fgift_place.png" | "fgift_move.png";
  tid: string;
  limited?: boolean;
}

const ORIGINAL_FREE_GIFTS: OriginalFreeGift[] = [
  { id: "fgift_008", name: "Mystery Briefcase", level: 1, background: "fgift_openBox.png", tid: "FGT_FGIFT_003" },
  { id: "fgift_033", name: "Santa's Sleigh", level: 8, background: "fgift_place.png", tid: "FGT_FGIFT_029", limited: true },
  { id: "fgift_019", name: "Mystery safe", level: 12, background: "fgift_openBox.png", tid: "TID_FGIFT_016" },
  { id: "fgift_034", name: "New Year Balloons", level: 12, background: "fgift_place.png", tid: "FGT_FGIFT_030", limited: true },
  { id: "fgift_031", name: "Urban Rockstar", level: 0, background: "fgift_place.png", tid: "FGT_FGIFT_026" },
  { id: "fgift_030", name: "Millionaire Rockstar", level: 0, background: "fgift_place.png", tid: "FGT_FGIFT_027" },
  { id: "fgift_017", name: "Sidewalk", level: 3, background: "fgift_place.png", tid: "FGT_FGIFT_014" },
  { id: "fgift_010", name: "Urban Tree", level: 5, background: "fgift_place.png", tid: "FGT_FGIFT_007" },
  { id: "fgift_021", name: "Mailbox", level: 8, background: "fgift_place.png", tid: "FGT_FGIFT_018" },
  { id: "fgift_020", name: "Telephone Box", level: 12, background: "fgift_place.png", tid: "FGT_FGIFT_017" },
  { id: "fgift_029", name: "Crosschannels", level: 10, background: "fgift_place.png", tid: "FGT_FGIFT_023" },
  { id: "fgift_027", name: "Upper Channel", level: 7, background: "fgift_place.png", tid: "FGT_FGIFT_024" },
  { id: "fgift_028", name: "Lower Channel", level: 7, background: "fgift_place.png", tid: "FGT_FGIFT_025" },
  { id: "fgift_025", name: "Channel left", level: 7, background: "fgift_place.png", tid: "FGT_FGIFT_021" },
  { id: "fgift_026", name: "Channel right", level: 7, background: "fgift_place.png", tid: "FGT_FGIFT_022" },
  { id: "fgift_011", name: "Urban Bench", level: 10, background: "fgift_place.png", tid: "FGT_FGIFT_008" },
  { id: "fgift_012", name: "Bus Stop", level: 20, background: "fgift_place.png", tid: "FGT_FGIFT_009" },
  { id: "fgift_016", name: "MCity Police", level: 30, background: "fgift_place.png", tid: "FGT_FGIFT_013" },
  { id: "fgift_013", name: "Ice Cream Cart", level: 40, background: "fgift_place.png", tid: "FGT_FGIFT_010" },
  { id: "fgift_014", name: "Traffic Lights", level: 15, background: "fgift_place.png", tid: "FGT_FGIFT_011" },
  { id: "fgift_015", name: "Street Sign", level: 6, background: "fgift_place.png", tid: "FGT_FGIFT_012" },
  { id: "fgift_006", name: "Spring Flower", level: 15, background: "fgift_place.png", tid: "FGT_FGIFT_005" },
  { id: "fgift_007", name: "Lemon Tree", level: 1, background: "fgift_place.png", tid: "FGT_FGIFT_002" },
  { id: "fgift_001", name: "Free move", level: 1, background: "fgift_move.png", tid: "FGT_FGIFT_001" },
  { id: "fgift_002", name: "2 Free moves", level: 15, background: "fgift_move.png", tid: "FGT_FGIFT_004" },
  { id: "fgift_003", name: "3 Free moves", level: 25, background: "fgift_move.png", tid: "FGT_FGIFT_004_2" }
];

export function renderLauncherHtml(options: LauncherOptions): string {
  const gameAssetsBaseUrl = options.gameAssetsBaseUrl ?? options.assetsBaseUrl;
  const gameVersion = options.gameVersion ?? GAME_VERSION;
  const clientSwfUrl = options.clientSwfUrl ?? "/client/Dollars.private.swf";
  const flashVars = new URLSearchParams({
    token: options.gameToken,
    uid: options.userId,
    env: "private",
    fan_page_id: options.facebookAppId,
    oauth_token: options.oauthToken,
    facebook_app_id: options.facebookAppId,
    server: options.serverBaseUrl,
    data: gameAssetsBaseUrl,
    game_version: gameVersion,
    xml_version: gameVersion,
    usr_level: "1",
    wcrm_env: "2",
    wcrm_user: options.userId,
    wcrm_server: options.serverBaseUrl,
    wcrm_visible_at: "0",
    swf_version: "0",
    lang: options.lang,
    fed_currency_id: "9",
    fed_url: options.serverBaseUrl,
    fed_game_id: "Dollar_Facebook",
    fed_payments: "0",
    fed_post_payment_url: `${options.appUrl}/launcher`,
    analytics_code: "null",
    useFrictionlessFacebookCredits: "false",
    bartUrl: options.serverBaseUrl,
    allFriendsAreNeighbors: "0",
    debugMode: options.debugMode ? "1" : "0",
    climateMode: options.climateMode ? "1" : "0",
    oldItemDesigns: options.oldItemDesigns ? "1" : "0",
    console: options.debugMode ? "1" : "0"
  }).toString();

  const cssUrl = `${options.assetsBaseUrl}css/main-style.css`;
  const connectCssUrl = `${options.assetsBaseUrl}css/connect.css`;
  const faceboxCssUrl = `${options.assetsBaseUrl}facebox/facebox.css`;
  const loadingBackgroundUrl = `${options.assetsBaseUrl}pages/Background_loading.png`;
  const faviconUrl = `${options.appUrl}/favicon.ico`;
  const cbarUrl = `${options.appUrl}/cbar/cbar.htm`;
  const tabSkylineUrl = `${options.assetsBaseUrl}tabs/social_wall/general/skyline.png`;
  const logoUrl = `${options.assetsBaseUrl}tabs/social_wall/general/logo.png`;
  const giftIconUrl = `${options.assetsBaseUrl}tabs/social_wall/general/gift.png`;
  const neighborIconUrl = `${options.assetsBaseUrl}tabs/social_wall/general/neighboor.png`;
  const messagesIconUrl = `${options.assetsBaseUrl}tabs/social_wall/general/messages.png`;
  const giftSidewalkUrl = `${options.assetsBaseUrl}tabs/free_gifts/fgift_017.png`;
  const localUserName = escapeHtml(options.localUserName);
  const localCityName = escapeHtml(options.localCityName);
  const localProfilePictureUrl = escapeAttribute(options.localProfilePictureUrl);
  const localProfileBootstrapJson = escapeScriptJson(JSON.stringify({
    userName: options.localUserName,
    cityName: options.localCityName,
    profilePictureUrl: options.localProfilePictureUrl
  }));
  const advisorNameJson = escapeScriptJson(JSON.stringify(options.advisorName ?? "Ronald"));
  const launcherUserIdJson = escapeScriptJson(JSON.stringify(options.userId));
  const socialAssetsPathJson = escapeScriptJson(JSON.stringify(options.assetsBaseUrl.replace(/\/$/, "")));
  const launcherLocaleJson = escapeScriptJson(JSON.stringify(options.lang));
  const freeGiftCardsHtml = ORIGINAL_FREE_GIFTS.map((gift) => {
    const giftImageUrl = `${options.assetsBaseUrl}tabs/free_gifts/${gift.id}.png`;
    const lockedGiftImageUrl = `${options.assetsBaseUrl}tabs/free_gifts/${gift.id}_locked.png`;
    const giftBackgroundUrl = `${options.assetsBaseUrl}tabs/free_gifts/${gift.background}`;
    const limitedBadge = gift.limited
      ? `<div class="limited-time"><img src="${options.assetsBaseUrl}tabs/free_gifts/limited_text.png" alt="" /></div>`
      : "";

    return `
              <div class="gift-block" level="${gift.level}" style="background-image: url('${giftBackgroundUrl}')">
                <div class="blue-text freeGiftText"><span>${escapeHtml(gift.name)}</span></div>
                <img src="${giftImageUrl}" class="unlocked-image" alt="" />
                <img src="${lockedGiftImageUrl}" class="locked-image" alt="" />
                <p><span class="blue-text lockedGiftText">Level ${gift.level} needed</span></p>
                <span class="uiButton uiButtonConfirm freeGiftButton" id="${gift.id}" level="${gift.level}" tid="${gift.tid}">Send Gift</span>
                ${limitedBadge}
              </div>`;
  }).join("");

  return `<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="X-UA-Compatible" content="IE=8" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Millionaire City</title>
    <link rel="icon" type="image/x-icon" href="${faviconUrl}" />
    <link rel="stylesheet" type="text/css" href="${cssUrl}" />
    <link rel="stylesheet" type="text/css" href="${connectCssUrl}" />
    <link rel="stylesheet" type="text/css" href="${faceboxCssUrl}" />
    <script src="${options.appUrl}/local/jquery.min.js"></script>
    <script src="${options.appUrl}/local/social-wall.js"></script>
    <script>
      (function() {
        try {
          if (localStorage.getItem("mcity.localProfileSettingsVisible") === "0") {
            document.documentElement.className += " local-profile-settings-hidden";
          }
        } catch (error) {
        }
      })();
    </script>
    <style>
      html,
      body {
        min-height: 100%;
      }

      body {
        background:
          linear-gradient(180deg, #89d7ef 0%, #d9f3fb 160px, #f5f2eb 360px, #f5f2eb 100%);
        color: #35566f;
      }

      #page {
        position: relative;
        width: 760px;
        margin: 0 auto;
        min-height: 780px;
        padding-top: 8px;
      }

      #fb-root,
      #toolTipBox,
      #EMBEDDED_DIV_ID,
      #mobius_submit {
        display: none;
      }

      #wcrm_cbar {
        width: 760px;
        height: 131px;
        margin: 0 auto;
        overflow: hidden;
        background: #ffffff;
      }

      #wcrm_cbar iframe {
        display: block;
        width: 760px;
        height: 131px;
        border: 0;
      }

      #tab-bar {
        position: relative;
        z-index: 1001;
        display: block;
        overflow: hidden;
        height: 65px;
        margin: 0;
        padding-left: 10px;
        background: #94dff4 url('${tabSkylineUrl}') bottom repeat-x;
        text-align: left;
        vertical-align: bottom;
      }

      #tab-bar-top {
        display: none;
      }

      #mcity_logo {
        position: absolute;
        top: 0;
        left: 0;
        display: block;
        width: 100%;
        height: 60px;
        background: transparent url('${logoUrl}') right center no-repeat;
        pointer-events: none;
      }

      #tab_bar_buttons {
        position: absolute;
        top: 0;
        left: 0;
        width: 360px;
        height: 65px;
        overflow: visible;
        padding-left: 0;
        background: transparent none;
        text-align: left;
      }

      #tab_bar_buttons > .tab-label {
        display: inline-block;
        width: 88px;
        min-width: 88px;
        height: 60px;
        margin: 0;
        padding: 3px 6px 0;
        border: 0 !important;
        background: transparent none !important;
        color: #2e3c85;
        cursor: pointer;
        line-height: 12px;
        text-align: center;
        vertical-align: top;
        white-space: normal;
      }

      #tab_bar_buttons > .tab-label.tab-selected {
        color: #ee0951;
      }

      #tab-bar .tab-label {
        position: relative;
        z-index: 2;
      }

      #tab_bar_buttons > .tab-label:hover {
        top: 0;
        color: #ee0951 !important;
      }

      #tab-bar .tab-icon {
        display: inline-block;
        width: 34px;
        height: 34px;
        margin: 0 auto;
        object-fit: contain;
        vertical-align: top;
      }

      #gameEmbed {
        visibility: visible;
        position: relative;
        width: 760px;
        height: 600px;
        margin-top: -1px;
        background: #ffffff url('${loadingBackgroundUrl}') top center no-repeat;
        box-shadow: 0 6px 18px rgba(28, 56, 82, 0.18);
      }

      #game_frame {
        width: 760px;
        height: 600px;
      }

      object {
        width: 760px;
        height: 600px;
        display: block;
        background: transparent;
      }

      .panel_button {
        display: inline-block;
        min-width: 110px;
        margin-right: 8px;
        padding: 6px 10px;
        border: 1px solid #8fb1cb;
        border-radius: 14px;
        background: linear-gradient(180deg, #ffffff 0%, #dcecf7 100%);
        color: #2f5572;
        font-size: 11px;
        font-weight: bold;
        text-align: center;
      }

      #gifts,
      #neighbors,
      #dcsw {
        display: none;
        visibility: hidden;
        z-index: 1000;
        height: auto;
      }

      .gifts_close,
      .nb_close,
      .dcsw_close {
        z-index: 1;
      }

      #nb_footer {
        cursor: pointer;
      }

      .curtain {
        position: fixed;
        top: 0;
        right: 0;
        bottom: 0;
        left: 0;
        width: auto !important;
        height: auto !important;
      }

      #local_profile_settings {
        margin-top: 12px;
        padding: 10px 14px;
        border: 1px solid #c7e2f4;
        border-radius: 10px;
        background: linear-gradient(180deg, #ffffff 0%, #edf8ff 100%);
        color: #35566f;
        font-size: 12px;
      }

      .local-profile-settings-hidden #local_profile_settings {
        display: none;
      }

      #local_profile_settings summary {
        color: #1d669f;
        cursor: pointer;
        font-weight: bold;
      }

      #local_profile_form {
        display: flex;
        flex-wrap: wrap;
        align-items: flex-end;
        gap: 12px;
        margin-top: 10px;
      }

      #local_resources_form {
        display: flex;
        flex-direction: column;
        align-items: stretch;
        gap: 8px;
        margin-top: 12px;
        padding-top: 12px;
        border-top: 1px solid #d7edf8;
      }

      .local_resource_controls {
        display: flex;
        flex-wrap: wrap;
        align-items: flex-end;
        gap: 10px;
      }

      .local_resource_group {
        display: flex;
        flex: 1 1 190px;
        flex-wrap: wrap;
        align-items: flex-start;
        gap: 5px;
        min-width: 0;
      }

      .local_resource_group .local_profile_field {
        flex: 1 1 100%;
      }

      .local_profile_field {
        display: inline-block;
      }

      .local_profile_field label {
        display: block;
        margin-bottom: 4px;
        color: #4b6f8a;
        font-weight: bold;
      }

      #local_profile_name {
        width: 160px;
        padding: 4px 6px;
        border: 1px solid #9fc0d8;
        border-radius: 6px;
      }

      #local_city_name {
        width: 160px;
        padding: 4px 6px;
        border: 1px solid #9fc0d8;
        border-radius: 6px;
      }

      .local_resource_amount {
        box-sizing: border-box;
        width: 100%;
        padding: 4px 6px;
        border: 1px solid #9fc0d8;
        border-radius: 6px;
      }

      .local_resource_group .panel_button {
        flex: 1 1 0;
        min-width: 0;
        margin-right: 0;
        padding: 5px 6px;
        text-align: center;
        white-space: nowrap;
      }

      #local_resources_summary {
        color: #4b6f8a;
        font-weight: bold;
      }

      #local_profile_picture_preview {
        display: block;
        flex: 0 0 50px;
        width: 50px !important;
        height: 50px !important;
        max-width: 50px !important;
        max-height: 50px !important;
        border: 1px solid #9fc0d8;
        border-radius: 6px;
        background: #ffffff;
        object-fit: cover;
        overflow: hidden;
      }

      #local_profile_status {
        display: block;
        flex: 1 1 100%;
        color: #607b91;
        min-width: 0;
        line-height: 1.3;
      }

      #local_profile_status.profile-error {
        color: #b43737;
      }

      #local_profile_status.profile-ok {
        color: #2d7b42;
      }

      #local_resources_status {
        color: #607b91;
        min-width: 190px;
      }

      #local_resources_status.resources-error {
        color: #b43737;
      }

      #local_resources_status.resources-ok {
        color: #2d7b42;
      }

      #footer {
        margin-top: 16px;
      }

      #footer #links a {
        white-space: nowrap;
      }
    </style>
  </head>
  <body>
    <div id="fb-root"></div>
    <div id="page">
      <div id="wcrm_cbar">
        <iframe title="Digital Chocolate Bar" src="${cbarUrl}" scrolling="no"></iframe>
      </div>

      <div id="tab-bar" class="tab-bar-new">
        <div id="tab-bar-top" class="tab-bar-new-top"></div>
        <div class="mcity_logo" id="mcity_logo"></div>
        <div class="tab-bar-new" id="tab_bar_buttons">
          <span class="tab-label rounded" id="labelFor_gifts">
            <img class="tab-icon" src="${giftIconUrl}" data-base-src="${giftIconUrl}" alt="" />
            <br />
            Free Gifts
          </span>
          <span class="tab-label rounded" id="labelFor_neighbors">
            <img class="tab-icon" src="${neighborIconUrl}" data-base-src="${neighborIconUrl}" alt="" />
            <br />
            My Neighbors
          </span>
          <span class="tab-label rounded" id="labelFor_dcsw">
            <img class="tab-icon" src="${messagesIconUrl}" data-base-src="${messagesIconUrl}" alt="" />
            <br />
            Messages
          </span>
          <span id="dcsw_requests_counter" class="counter-new"></span>
        </div>
      </div>

      <span id="toolTipBox"></span>

      <div id="gameEmbed" class="tab-content">
        <div id="game_frame">
          <object id="flash" name="flash" type="application/x-shockwave-flash" data="${clientSwfUrl}">
            <param name="movie" value="${clientSwfUrl}" />
            <param name="quality" value="high" />
            <param name="align" value="middle" />
            <param name="play" value="true" />
            <param name="loop" value="true" />
            <param name="scale" value="showall" />
            <param name="wmode" value="transparent" />
            <param name="devicefont" value="false" />
            <param name="bgcolor" value="#ffffff" />
            <param name="menu" value="true" />
            <param name="allowScriptAccess" value="always" />
            <param name="allowFullScreen" value="true" />
            <param name="FlashVars" value="${flashVars}" />
          </object>
        </div>
        <noscript>You need to enable JavaScript in order to play this game.</noscript>
      </div>

      <div id="neighbors" class="tab-content rounded-shadow"></div>

      <div id="gifts" class="tab-content rounded-shadow">
        <span class="gifts_close" id="gifts_close">&nbsp;</span>
        <div id="gifts_header"></div>
        <div class="gifts_outer">
          <div id="gifts_body">
            <h1 class="blue-text">Send a gift to your friends</h1>
            <div class="gifts_suggestion_box">
              <div style="display:inline-block;width:128px;margin:10px;">
                <img src="${giftSidewalkUrl}" alt="" />
              </div>
              <div style="display:inline-block;width:360px;">
                <p class="blue-text"><span id="username"></span> and some other friends were getting profits sending Free Gifts yesterday</p>
                <br />
                <div id="gifts_friends_faces"></div>
              </div>
              <div style="display:inline-block;vertical-align:text-bottom;width:150px;height:60px;">
                <p class="uiButton uiButtonConfirm freeGiftButton" id="suggested_gift" style="top:0px;vertical-align:middle;padding:14px;" tid="FGT_FGIFT_014">Send Gift</p>
              </div>
            </div>

            <h1 class="blue-text">or choose a gift below!</h1>
            <div id="gifts_feedback" class="blue-text" style="display:none; text-align:center">Your gift was sent!</div>
            <div class="gifts_inner">
${freeGiftCardsHtml}
            </div>
          </div>
        </div>
        <div id="gifts_footer"></div>
      </div>

      <div id="dcsw" class="tab-content rounded-shadow"></div>

      <div id="wcrm_footer"></div>

      <details id="local_profile_settings">
        <summary>Local Profile Settings</summary>
        <div id="local_profile_form">
          <img id="local_profile_picture_preview" src="${localProfilePictureUrl}" alt="" />
          <div class="local_profile_field">
            <label for="local_profile_name">Player Name</label>
            <input id="local_profile_name" type="text" maxlength="32" value="${localUserName}" />
          </div>
          <div class="local_profile_field">
            <label for="local_city_name">City Name</label>
            <input id="local_city_name" type="text" maxlength="32" value="${localCityName}" />
          </div>
          <div class="local_profile_field">
            <label for="local_profile_picture">Profile Picture</label>
            <input id="local_profile_picture" type="file" accept="image/png,image/jpeg,image/gif,image/webp" />
          </div>
          <button class="panel_button" id="local_profile_save" type="button">Save Profile</button>
          <button class="panel_button" id="local_profile_clear_picture" type="button">Remove Picture</button>
          <span id="local_profile_status"></span>
        </div>
        <div id="local_resources_form">
          <div id="local_resources_summary">Loading money, gold, and XP...</div>
          <div class="local_resource_controls">
            <div class="local_resource_group">
              <div class="local_profile_field">
                <label for="local_money_amount">Money</label>
                <input class="local_resource_amount" id="local_money_amount" type="number" min="1" step="1" value="100000" />
              </div>
              <button class="panel_button" id="local_money_add" type="button">Add Money</button>
              <button class="panel_button" id="local_money_remove" type="button">Remove Money</button>
            </div>
            <div class="local_resource_group">
              <div class="local_profile_field">
                <label for="local_gold_amount">Gold</label>
                <input class="local_resource_amount" id="local_gold_amount" type="number" min="1" step="1" value="100" />
              </div>
              <button class="panel_button" id="local_gold_add" type="button">Add Gold</button>
              <button class="panel_button" id="local_gold_remove" type="button">Remove Gold</button>
            </div>
            <div class="local_resource_group">
              <div class="local_profile_field">
                <label for="local_xp_amount">XP</label>
                <input class="local_resource_amount" id="local_xp_amount" type="number" min="1" step="1" value="1000" />
              </div>
              <button class="panel_button" id="local_xp_add" type="button">Add XP</button>
              <button class="panel_button" id="local_xp_remove" type="button">Remove XP</button>
            </div>
          </div>
          <span id="local_resources_status"></span>
        </div>
      </details>

      <div id="footer">
        <div id="links">
          <a href="javascript:void(0)" onclick="return false;">Millionaire City Fan Page</a> |
          <a href="javascript:void(0)" onclick="return false;">ToS</a> |
          <a href="javascript:void(0)" onclick="return false;">Privacy &amp; Security</a> |
          <a href="javascript:void(0)" onclick="return false;">FAQ</a> |
          <a href="javascript:void(0)" onclick="return false;">Forums</a> |
          <a href="javascript:void(0)" onclick="return false;">Support</a> |
          <a href="javascript:void(0)" onclick="return false;">Tips and Tricks</a> |
          <a href="javascript:void(0)" onclick="return false;">Twitter</a>
        </div>
        <div id="copyright">
          Millionaire City v.${gameVersion}, Copyright &copy; Digital Chocolate 2010. All Rights Reserved
        </div>
      </div>
    </div>

    <div id="EMBEDDED_DIV_ID"></div>
    <a href="#" id="mobius_submit" style="display:none;">Mobius</a>

    <script>
      var TASKS = {
        REQUEST_LEVEL: "RequestLevel",
        SEND_LEVEL: "sendLevel"
      };

      var FLASH_READY = false;
      var GIFTING_INTERSTITIAL_CLOSED = false;
      var SOCIAL_WALL_VISITED = false;
      var INITIAL_LOCAL_PROFILE = ${localProfileBootstrapJson};
      var LOCAL_ADVISOR_NAME = ${advisorNameJson};
      var LOCAL_USER_ID = ${launcherUserIdJson};
      var LOCAL_PROFILE_SETTINGS_STORAGE_KEY = "mcity.localProfileSettingsVisible";
      var tasksBuffer = [];
      var $j = window.jQuery;
      var LOCAL_SOCIAL_USERS = {
        "100": { id: "100", name: LOCAL_ADVISOR_NAME },
        "101": { id: "101", name: "Sheik" }
      };
      var FB = {
        init: function() {},
        getLoginStatus: function(callback) {
          if (typeof callback === "function") {
            callback({ authResponse: { userID: LOCAL_USER_ID } });
          }
        },
        api: function(path) {
          var args = Array.prototype.slice.call(arguments, 1);
          var callback = args.filter(function(value) { return typeof value === "function"; }).pop();
          var requestPath = String(path || "").split("?")[0];
          var response;
          if (requestPath === "/me/apprequests") {
            response = { data: [] };
          } else if (requestPath === "/me/friends") {
            response = { data: [LOCAL_SOCIAL_USERS["100"], LOCAL_SOCIAL_USERS["101"]] };
          } else {
            var socialId = requestPath.replace(/^\\//, "");
            response = LOCAL_SOCIAL_USERS[socialId] || { id: socialId, name: "" };
          }
          if (typeof callback === "function") {
            setTimeout(function() { callback(response); }, 0);
          }
          return response;
        },
        ui: function(options, callback) {
          var recipient = options && options.to ? String(options.to) : "100";
          if (typeof callback === "function") {
            setTimeout(function() {
              callback({ request_ids: ["local-" + recipient], to: [recipient] });
            }, 0);
          }
        },
        Canvas: {
          getPageInfo: function() { return { scrollTop: 0, scrollLeft: 0 }; },
          setSize: function() {}
        },
        Event: { subscribe: function() {} },
        XFBML: { parse: function() {} }
      };
      window.FB = FB;

      function getMovie(name) {
        return document[name] || document.getElementById(name) || window[name] || null;
      }

      function setStatus(title, text, className) {
        if (window.console && typeof window.console.debug === "function") {
          window.console.debug("[mcity] " + title + ": " + text);
        }
      }

      function notify(text, className) {
        setStatus("Private Server ${gameVersion}", text, className || "");
      }

      function sendTask_to_flash2(task, params) {
        var movie = getMovie("flash");
        if (movie != null && typeof movie.externalTaskResponse === "function" && FLASH_READY) {
          movie.externalTaskResponse(task, params == null ? null : params);
        } else {
          tasksBuffer.push({ task: task, params: params == null ? null : params });
        }
      }

      function sendTask_to_flash(task) {
        sendTask_to_flash2(task, null);
      }

      function sendDelayedTaskToFlash() {
        if (!FLASH_READY) {
          return;
        }
        var movie = getMovie("flash");
        if (movie == null || typeof movie.externalTaskResponse !== "function") {
          return;
        }
        while (tasksBuffer.length > 0) {
          var delayedTask = tasksBuffer.shift();
          movie.externalTaskResponse(delayedTask.task, delayedTask.params);
        }
      }

      function parsePayload(data) {
        if (!data) {
          return {};
        }
        try {
          return JSON.parse(data);
        } catch (error) {
          console.warn("Failed to parse wrapper payload.", error);
          return {};
        }
      }

      function privateServerUnavailable() {
        return undefined;
      }

      function removeCurtains() {
        var curtains = document.querySelectorAll(".curtain");
        curtains.forEach(function(curtain) {
          curtain.remove();
        });
      }

      function hidePanels() {
        ["gifts", "neighbors", "dcsw"].forEach(function(id) {
          var panel = document.getElementById(id);
          panel.style.display = "none";
          panel.style.visibility = "hidden";
        });
      }

      function clearTabSelection() {
        var labels = document.querySelectorAll(".tab-label");
        labels.forEach(function(label) {
          label.classList.remove("tab-selected");
        });
      }

      function showGameOnly() {
        clearTabSelection();
        hidePanels();
        removeCurtains();
        sendTask_to_flash("ShowGame");
        notify("Game tab active.", "status-ok");
      }

      function showCurtain() {
        removeCurtains();
        var curtain = document.createElement("div");
        curtain.id = "curtain_dcsw";
        curtain.className = "curtain";
        curtain.style.zIndex = "999";
        document.body.prepend(curtain);
      }

      function openPanel(panelId, labelId) {
        clearTabSelection();
        hidePanels();
        removeCurtains();
        var label = document.getElementById(labelId);
        var panel = document.getElementById(panelId);
        if (label) {
          label.classList.add("tab-selected");
        }
        if (panel) {
          panel.style.display = "block";
          panel.style.visibility = "visible";
        }
        showCurtain();
        sendTask_to_flash("HideGame");
        if (panelId === "dcsw" && window.DCSW && typeof window.DCSW.show === "function") {
          window.DCSW.show();
        }
        if (panelId === "gifts" || panelId === "dcsw") {
          updateLockedGifts();
        }
      }

      function clickOnTab(id) {
        if (id === "labelFor_gameEmbed") {
          showGameOnly();
          return;
        }
        if (id === "labelFor_gifts") {
          openPanel("gifts", id);
          return;
        }
        if (id === "labelFor_neighbors") {
          openPanel("neighbors", id);
          return;
        }
        if (id === "labelFor_dcsw") {
          openPanel("dcsw", id);
        }
      }

      function closeGiftTab() {
        showGameOnly();
      }

      function updateLockedGifts() {
        sendTask_to_flash(TASKS.REQUEST_LEVEL);
      }

      function unlockFreeGifts(level) {
        var playerLevel = parseInt(String(level), 10);
        if (isNaN(playerLevel)) {
          playerLevel = 0;
        }
        document.querySelectorAll(".gift-block").forEach(function(gift) {
          var giftLevel = parseInt(gift.getAttribute("level") || "0", 10);
          gift.classList.toggle("locked-gift", playerLevel < giftLevel);
        });
      }

      function setUserLocale() {
        return undefined;
      }

      function notifyWCRM_fromFlash() {
        return undefined;
      }

      function notifyWCRM() {
        return undefined;
      }

      function launchFacebookRequest(params, options, onSuccess) {
        var requestParams = params || {};
        var requestOptions = options || {};
        requestOptions.method = "apprequests";
        requestOptions.title = requestOptions.title || "Millionaire City";
        requestOptions.message = requestOptions.message || "Millionaire City";
        if (requestParams.fExtId != null) {
          requestOptions.to = String(requestParams.fExtId);
        }
        FB.ui(requestOptions, function(response) {
          if (!response || !response.request_ids || response.request_ids.length === 0) {
            return;
          }
          if (onSuccess && typeof onSuccess.method === "function") {
            onSuccess.method.call(onSuccess.object, requestParams);
          }
          if (requestParams.sku && window.jQuery) {
            window.jQuery("#gifts_feedback").stop(true, true).slideDown("slow").delay(3000).slideUp("slow");
          }
        });
      }

      function launchFacebookInvite() {
        launchFacebookRequest({ action: "neighborRequest" });
      }

      function initializeOriginalSocialPanels() {
        if (typeof window.DC_SocialWall !== "function" || typeof window.DC_Neighbors !== "function") {
          return;
        }
        window.i18n.config({
          DCSW_ERROR: "Sorry, there was an unexpected error.",
          DCSW_EMPTY: "You don't have any messages at the moment.",
          DCSW_ACCEPT: "Accept",
          DCSW_IGNORE: "Ignore",
          DCSW_SENDITBACK: "Send gift back?",
          DCSW_ALL_MESSAGES: "All messages",
          DCSW_BUSS_PARTNER_TAB: "Business Partners",
          DCSW_BUSS_PARTNER_TITLE: "%U:",
          DCSW_BUSS_PARTNER_BODY: "Become my Business Partner to make money faster!",
          DCSW_BUSS_PARTNER_ACCEPTED: "Congrats - You have a new Business Partner!",
          DCSW_COLLECTIBLES_TAB: "Collectibles",
          DCSW_COLLECTIBLES_TITLE: "%U:",
          DCSW_COLLECTIBLES_BODY: "You got an exciting parcel with a luxurious Collectible!",
          DCSW_COLLECTIBLES_ACCEPTED: "You got a collectible from your friend!",
          DCSW_GIFT_TAB: "Free Gifts",
          DCSW_GIFT_TITLE: "%U:",
          DCSW_GIFT_BODY: "Here is a free gift to help you out!",
          DCSW_GIFT_ACCEPTED: "You got the %U!",
          DCSW_GIFT_EXPIRED: "Oops! Your gift has expired! Check more often to accept gifts.",
          DCSW_NEIGHBOR_TAB: "Neighbors requests",
          DCSW_NEIGHBOR_TITLE: "%U:",
          DCSW_NEIGHBOR_BODY: "Become my neighbor to make money faster!",
          DCSW_NEIGHBOR_ACCEPTED: "Congrats - You have a new neighbor!",
          DCSW_CREW_TAB: "Staff Invites",
          DCSW_CREW_TITLE: "%U:",
          DCSW_CREW_BODY: "Please help me to open a new club",
          DCSW_CREW_ACCEPTED: "Congrats - you were hired!",
          DCSW_CREW_EXPIRED: "You already accepted this invite",
          DCSW_CREW_ALREADY_FILLED: "This position was already filled",
          CREW_NEIGHBORS_NEEDED: "You need more neighbors to accomplish this action",
          DCSW_EMPTY_GIFTS: "You have no Gifts at the moment. Send gifts to friends here to get some back!",
          DCSW_EMPTY_NEIGHBORS: "You have no Neighbors request at the moment. Send them here to make more money with your friends!",
          DCSW_EMPTY_PARTNERS: "You have no Business Partners requests at the moment. Send them here to make more money with your friends!",
          DCSW_EMPTY_NEIGHBORS_BUTTON: "Send Neighbors Request",
          DCSW_EMPTY_PARTNERS_BUTTON: "Send Business Partner Request",
          FGT_TITLE: "Send a gift to your friends",
          MYNEIGHBORS_TAB: "My Neighbors",
          INVITE_FRIENDS: "Invite friends",
          MNT_TITLE: "Add more neighbors!",
          MNT_SEND_BUTTON: "Add as a neighbor",
          MNT_SEND_REMINDER_BUTTON: "Send reminder",
          MNT_ADDME: "Add me as a neighbor!",
          MNT_PENDING: "Neighbor request pending",
          MNT_REMOVE: "Remove",
          FGT_SEND_BUTTON: "Send Gift"
        });
        var socialConfig = {
          ASSETS_PATH: ${socialAssetsPathJson},
          GIFT_BACK_CALLBACK: launchFacebookRequest,
          LOCALE: ${launcherLocaleJson}
        };
        window.DCSW = new window.DC_SocialWall("dcsw", "dcsw_requests_counter", socialConfig);
        window.DCNB = new window.DC_Neighbors("neighbors", LOCAL_USER_ID, "local", "local", socialConfig);
        window.DCSW.getAllRequests(LOCAL_USER_ID, "local", false);
        window.DCSW.show();
        setInterval(function() { window.DCSW.getNewRequests(LOCAL_USER_ID, "local", false); }, 60000);
        setInterval(function() { window.DCNB.reload(); }, 60000);
        var username = document.getElementById("username");
        if (username) {
          username.textContent = LOCAL_ADVISOR_NAME;
        }
      }

      function launchCashShop() {
        privateServerUnavailable("cashShop");
      }

      function launchCashShopStandalone() {
        privateServerUnavailable("cashShopStandalone");
      }

      function postToFeed() {
        privateServerUnavailable("postToFeed");
      }

      function launchBecomeFan() {
        sendTask_to_flash("messageFanPopupClosed");
      }

      function launchFacebookCredits() {
        sendTask_to_flash("messageResponseFacebookCredits:1");
      }

      function launchGetFBCreditsBalance() {
        sendTask_to_flash("fbcreditsCurrentBalance:0:0");
      }

      function showFacebox() {
        privateServerUnavailable("showFacebox");
      }

      function fedPayment() {
        sendTask_to_flash("messageResponseFacebookCredits:1");
      }

      function showCRM() {
        privateServerUnavailable("showCRM");
      }

      function launchBookmark() {
        return undefined;
      }

      function showGamePopup() {
        return undefined;
      }

      function checkInGameAdInventory(availableCallbackName) {
        var movie = getMovie("flash");
        if (movie && typeof movie[availableCallbackName] === "function") {
          movie[availableCallbackName](false, "");
        }
      }

      function checkInGameAd() {
        checkInGameAdInventory("videoAdAvailableResponse", "videoAdCompleteResponse", "videoAdIncompleteResponse");
      }

      function videoAdCompleteResponse() {
        return undefined;
      }

      function videoAdIncompleteResponse() {
        return undefined;
      }

      function flashRequest_Received(task, data) {
        if (task === "helpSendFreeGift") {
          launchFacebookRequest(parsePayload(data));
          return;
        }
        if (task === "cashShop") {
          launchCashShop(parsePayload(data));
          return;
        }
        if (task === "cashShopStandalone") {
          launchCashShopStandalone();
          return;
        }
        if (task === "postToFeed") {
          postToFeed(data);
          return;
        }
        if (task === "becameFan") {
          launchBecomeFan();
          return;
        }
        if (task === "browserRefresh") {
          window.location.reload();
          return;
        }
        if (task === "facebookCredits") {
          launchFacebookCredits(data);
          return;
        }
        if (task === "getFBCreditsBalance") {
          launchGetFBCreditsBalance();
          return;
        }
        if (task === "fbRequest") {
          launchFacebookRequest(parsePayload(data));
          return;
        }
        if (task === "openURL") {
          privateServerUnavailable("External links");
          return;
        }
        if (task === "showFacebox") {
          showFacebox(data);
          return;
        }
        if (task === "fedPayment") {
          fedPayment(data);
          return;
        }
        if (task === "showCRM") {
          showCRM(data);
          return;
        }
        if (task === "ready") {
          FLASH_READY = true;
          pushInitialLocalProfileToFlash();
          sendDelayedTaskToFlash();
          return;
        }
        if (task === TASKS.SEND_LEVEL) {
          var levelData = parsePayload(data);
          unlockFreeGifts(levelData.level || 0);
          return;
        }
        return undefined;
      }

      function setLocalProfileStatus(message, isError) {
        var status = document.getElementById("local_profile_status");
        if (!status) {
          return;
        }
        status.textContent = message;
        status.classList.remove("profile-ok");
        status.classList.remove("profile-error");
        status.classList.add(isError ? "profile-error" : "profile-ok");
      }

      function resizeLocalProfilePicture(dataUrl, callback) {
        var image = new Image();
        image.onload = function() {
          var sourceWidth = image.naturalWidth || image.width;
          var sourceHeight = image.naturalHeight || image.height;
          if (!sourceWidth || !sourceHeight) {
            setLocalProfileStatus("Could not read that profile picture size.", true);
            return;
          }

          var thumbnailSize = 50;
          var canvas = document.createElement("canvas");
          var context = canvas.getContext("2d");
          var cropSize = Math.min(sourceWidth, sourceHeight);
          var cropX = Math.floor((sourceWidth - cropSize) / 2);
          var cropY = Math.floor((sourceHeight - cropSize) / 2);
          canvas.width = thumbnailSize;
          canvas.height = thumbnailSize;
          if (context.imageSmoothingEnabled !== undefined) {
            context.imageSmoothingEnabled = true;
          }
          if (context.imageSmoothingQuality !== undefined) {
            context.imageSmoothingQuality = "high";
          }
          context.clearRect(0, 0, thumbnailSize, thumbnailSize);
          context.drawImage(image, cropX, cropY, cropSize, cropSize, 0, 0, thumbnailSize, thumbnailSize);
          callback(canvas.toDataURL("image/png"));
        };
        image.onerror = function() {
          setLocalProfileStatus("Could not load that profile picture.", true);
        };
        image.src = dataUrl;
      }

      function readLocalProfilePicture(callback) {
        var input = document.getElementById("local_profile_picture");
        var file = input && input.files && input.files[0] ? input.files[0] : null;
        if (!file) {
          callback(null);
          return;
        }
        if (!/^image\\/(png|jpeg|gif|webp)$/.test(file.type)) {
          setLocalProfileStatus("Use a PNG, JPEG, GIF, or WebP image.", true);
          return;
        }
        if (file.size > 2 * 1024 * 1024) {
          setLocalProfileStatus("Profile picture must be 2 MB or smaller.", true);
          return;
        }

        var reader = new FileReader();
        reader.onload = function() {
          resizeLocalProfilePicture(String(reader.result || ""), callback);
        };
        reader.onerror = function() {
          setLocalProfileStatus("Could not read that profile picture.", true);
        };
        reader.readAsDataURL(file);
      }

      function getAbsoluteLocalUrl(path) {
        if (/^https?:\\/\\//i.test(String(path || ""))) {
          return path;
        }
        return window.location.protocol + "//" + window.location.host + path;
      }

      function pushLocalProfileToFlash(data) {
        sendTask_to_flash2("localProfileUpdate", JSON.stringify({
          userName: data.userName,
          cityName: data.cityName,
          profilePictureUrl: getAbsoluteLocalUrl(data.profilePictureUrl)
        }));
      }

      function pushInitialLocalProfileToFlash() {
        var delays = [0, 500, 1500, 3000];
        delays.forEach(function(delay) {
          setTimeout(function() {
            pushLocalProfileToFlash(INITIAL_LOCAL_PROFILE);
          }, delay);
        });
      }

      function getLocalProfileSettingsVisible() {
        try {
          return localStorage.getItem(LOCAL_PROFILE_SETTINGS_STORAGE_KEY) !== "0";
        } catch (error) {
          return true;
        }
      }

      function setLocalProfileSettingsVisible(visible) {
        var shouldShow = visible !== false;
        var panel = document.getElementById("local_profile_settings");
        document.documentElement.classList.toggle("local-profile-settings-hidden", !shouldShow);
        if (panel) {
          panel.hidden = !shouldShow;
        }
        try {
          localStorage.setItem(LOCAL_PROFILE_SETTINGS_STORAGE_KEY, shouldShow ? "1" : "0");
        } catch (error) {
        }
        return shouldShow;
      }

      function submitLocalProfile(clearPicture) {
        var nameInput = document.getElementById("local_profile_name");
        var cityInput = document.getElementById("local_city_name");
        var payload = {
          userName: nameInput ? nameInput.value : "",
          cityName: cityInput ? cityInput.value : ""
        };

        function postProfile(profilePictureDataUrl) {
          if (clearPicture) {
            payload.clearProfilePicture = true;
          } else if (profilePictureDataUrl) {
            payload.profilePictureDataUrl = profilePictureDataUrl;
          }

          fetch("/local/profile", {
            method: "POST",
            headers: { "content-type": "application/json" },
            body: JSON.stringify(payload)
          })
            .then(function(response) {
              return response.json().then(function(data) {
                if (!response.ok) {
                  throw new Error(data.error || "Could not save profile.");
                }
                return data;
              });
            })
            .then(function(data) {
              var username = document.getElementById("username");
              var preview = document.getElementById("local_profile_picture_preview");
              if (username) {
                username.textContent = data.userName;
              }
              if (nameInput) {
                nameInput.value = data.userName;
              }
              if (cityInput) {
                cityInput.value = data.cityName;
              }
              if (preview) {
                preview.src = data.profilePictureUrl;
              }
              pushLocalProfileToFlash(data);
              setLocalProfileStatus("Saved. Game profile updated.", false);
            })
            .catch(function(error) {
              setLocalProfileStatus(error.message || "Could not save profile.", true);
            });
        }

        if (clearPicture) {
          postProfile(null);
          return;
        }

        readLocalProfilePicture(postProfile);
      }

      function bindLocalProfileSettings() {
        var saveButton = document.getElementById("local_profile_save");
        var clearButton = document.getElementById("local_profile_clear_picture");
        var input = document.getElementById("local_profile_picture");
        if (saveButton) {
          saveButton.addEventListener("click", function() {
            submitLocalProfile(false);
          });
        }
        if (clearButton) {
          clearButton.addEventListener("click", function() {
            submitLocalProfile(true);
          });
        }
        if (input) {
          input.addEventListener("change", function() {
            readLocalProfilePicture(function(dataUrl) {
              var preview = document.getElementById("local_profile_picture_preview");
              if (preview && dataUrl) {
                preview.src = dataUrl;
              }
            });
          });
        }
      }

      function setLocalResourcesStatus(message, isError) {
        var status = document.getElementById("local_resources_status");
        if (!status) {
          return;
        }
        status.textContent = message;
        status.classList.remove("resources-ok");
        status.classList.remove("resources-error");
        status.classList.add(isError ? "resources-error" : "resources-ok");
      }

      function formatLocalNumber(value) {
        var number = Number(value || 0);
        if (!isFinite(number)) {
          return "0";
        }
        return Math.floor(number).toLocaleString("en-US");
      }

      function updateLocalResourcesSummary(data) {
        var summary = document.getElementById("local_resources_summary");
        if (!summary) {
          return;
        }
        summary.textContent =
          "Money: " + formatLocalNumber(data.money) +
          " | Gold: " + formatLocalNumber(data.gold) +
          " | XP: " + formatLocalNumber(data.xp) +
          " | Level: " + formatLocalNumber(data.level) +
          " | Company: " + formatLocalNumber(data.companyValue);
      }

      function getLocalResourceSnapshotValue(data, key) {
        var value = Number(data && data[key] != null ? data[key] : 0);
        if (!isFinite(value)) {
          return 0;
        }
        return Math.max(0, Math.floor(value));
      }

      function pushLocalResourcesToFlash(data) {
        var task = [
          "localStatsUpdate",
          getLocalResourceSnapshotValue(data, "money"),
          getLocalResourceSnapshotValue(data, "gold"),
          getLocalResourceSnapshotValue(data, "xp"),
          Math.max(1, getLocalResourceSnapshotValue(data, "level")),
          getLocalResourceSnapshotValue(data, "minXp"),
          getLocalResourceSnapshotValue(data, "maxXp"),
          getLocalResourceSnapshotValue(data, "companyValue")
        ].join(":");
        sendTask_to_flash(task);
      }

      function loadLocalResources() {
        fetch("/local/resources")
          .then(function(response) {
            return response.json().then(function(data) {
              if (!response.ok) {
                throw new Error(data.error || "Could not load resources.");
              }
              return data;
            });
          })
          .then(function(data) {
            updateLocalResourcesSummary(data);
          })
          .catch(function(error) {
            setLocalResourcesStatus(error.message || "Could not load resources.", true);
          });
      }

      function readLocalResourceAmount(inputId) {
        var input = document.getElementById(inputId);
        var amount = input ? Number(input.value) : 0;
        if (!isFinite(amount) || Math.floor(amount) !== amount || amount <= 0) {
          setLocalResourcesStatus("Enter a positive whole number.", true);
          return null;
        }
        return amount;
      }

      function adjustLocalResource(resource, amount) {
        fetch("/local/resources/adjust", {
          method: "POST",
          headers: { "content-type": "application/json" },
          body: JSON.stringify({ resource: resource, delta: amount })
        })
          .then(function(response) {
            return response.json().then(function(data) {
              if (!response.ok) {
                throw new Error(data.error || "Could not adjust resources.");
              }
              return data;
            });
          })
          .then(function(data) {
            updateLocalResourcesSummary(data);
            pushLocalResourcesToFlash(data);
            setLocalResourcesStatus("Saved. Game totals updated.", false);
          })
          .catch(function(error) {
            setLocalResourcesStatus(error.message || "Could not adjust resources.", true);
          });
      }

      function bindLocalResourceSettings() {
        var moneyAdd = document.getElementById("local_money_add");
        var moneyRemove = document.getElementById("local_money_remove");
        var goldAdd = document.getElementById("local_gold_add");
        var goldRemove = document.getElementById("local_gold_remove");
        var xpAdd = document.getElementById("local_xp_add");
        var xpRemove = document.getElementById("local_xp_remove");

        if (moneyAdd) {
          moneyAdd.addEventListener("click", function() {
            var amount = readLocalResourceAmount("local_money_amount");
            if (amount != null) {
              adjustLocalResource("money", amount);
            }
          });
        }
        if (moneyRemove) {
          moneyRemove.addEventListener("click", function() {
            var amount = readLocalResourceAmount("local_money_amount");
            if (amount != null) {
              adjustLocalResource("money", -amount);
            }
          });
        }
        if (goldAdd) {
          goldAdd.addEventListener("click", function() {
            var amount = readLocalResourceAmount("local_gold_amount");
            if (amount != null) {
              adjustLocalResource("gold", amount);
            }
          });
        }
        if (goldRemove) {
          goldRemove.addEventListener("click", function() {
            var amount = readLocalResourceAmount("local_gold_amount");
            if (amount != null) {
              adjustLocalResource("gold", -amount);
            }
          });
        }
        if (xpAdd) {
          xpAdd.addEventListener("click", function() {
            var amount = readLocalResourceAmount("local_xp_amount");
            if (amount != null) {
              adjustLocalResource("xp", amount);
            }
          });
        }
        if (xpRemove) {
          xpRemove.addEventListener("click", function() {
            var amount = readLocalResourceAmount("local_xp_amount");
            if (amount != null) {
              adjustLocalResource("xp", -amount);
            }
          });
        }

        loadLocalResources();
      }

      function bindTabHover() {
        var labels = document.querySelectorAll(".tab-label");
        labels.forEach(function(label) {
          var img = label.querySelector(".tab-icon");
          if (!img) {
            return;
          }
          var baseSrc = img.getAttribute("data-base-src") || img.getAttribute("src");
          var hoverSrc = img.getAttribute("data-hover-src");
          label.addEventListener("mouseenter", function() {
            if (hoverSrc) {
              img.setAttribute("src", hoverSrc);
            }
          });
          label.addEventListener("mouseleave", function() {
            img.setAttribute("src", baseSrc);
          });
        });
      }

      window.TASKS = TASKS;
      window.getMovie = getMovie;
      window.sendTask_to_flash = sendTask_to_flash;
      window.sendTask_to_flash2 = sendTask_to_flash2;
      window.flashRequest_Received = flashRequest_Received;
      window.clickOnTab = clickOnTab;
      window.closeGiftTab = closeGiftTab;
      window.launchFacebookRequest = launchFacebookRequest;
      window.launchFacebookInvite = launchFacebookInvite;
      window.launchBookmark = launchBookmark;
      window.showGamePopup = showGamePopup;
      window.notifyWCRM_fromFlash = notifyWCRM_fromFlash;
      window.notifyWCRM = notifyWCRM;
      window.checkInGameAd = checkInGameAd;
      window.checkInGameAdInventory = checkInGameAdInventory;
      window.videoAdCompleteResponse = videoAdCompleteResponse;
      window.videoAdIncompleteResponse = videoAdIncompleteResponse;
      window.setUserLocale = setUserLocale;
      window.getLocalProfileSettingsVisible = getLocalProfileSettingsVisible;
      window.setLocalProfileSettingsVisible = setLocalProfileSettingsVisible;

      initializeOriginalSocialPanels();

      document.getElementById("labelFor_gifts").addEventListener("click", function() {
        clickOnTab("labelFor_gifts");
      });
      document.getElementById("labelFor_neighbors").addEventListener("click", function() {
        clickOnTab("labelFor_neighbors");
      });
      document.getElementById("labelFor_dcsw").addEventListener("click", function() {
        clickOnTab("labelFor_dcsw");
      });
      document.getElementById("gifts_close").addEventListener("click", closeGiftTab);
      document.querySelectorAll(".freeGiftButton").forEach(function(button) {
        button.addEventListener("click", function() {
          if (button.closest(".locked-gift")) {
            return;
          }
          var giftType = button.getAttribute("id");
          if (!giftType) {
            return;
          }
          if (giftType === "suggested_gift") {
            giftType = "fgift_017";
          }
          launchFacebookRequest({
            action: "sendFreeGift",
            sku: giftType,
            tid: button.getAttribute("tid") || ""
          });
        });
      });

      bindTabHover();
      unlockFreeGifts(1);
      setLocalProfileSettingsVisible(getLocalProfileSettingsVisible());
      bindLocalProfileSettings();
      bindLocalResourceSettings();
      setInterval(sendDelayedTaskToFlash, 1000);
      showGameOnly();
    </script>
  </body>
</html>`;
}

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function escapeAttribute(value: string): string {
  return escapeHtml(value);
}

function escapeScriptJson(value: string): string {
  return value
    .replace(/</g, "\\u003c")
    .replace(/>/g, "\\u003e")
    .replace(/&/g, "\\u0026")
    .replace(/\u2028/g, "\\u2028")
    .replace(/\u2029/g, "\\u2029");
}
