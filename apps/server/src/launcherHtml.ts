import { GAME_VERSION } from "@mcity/shared";

interface LauncherOptions {
  appUrl: string;
  assetsBaseUrl: string;
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
}

export function renderLauncherHtml(options: LauncherOptions): string {
  const flashVars = new URLSearchParams({
    token: options.gameToken,
    uid: options.userId,
    env: "private",
    fan_page_id: options.facebookAppId,
    oauth_token: options.oauthToken,
    facebook_app_id: options.facebookAppId,
    server: options.serverBaseUrl,
    data: options.assetsBaseUrl,
    game_version: GAME_VERSION,
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
  const giftMysteryUrl = `${options.assetsBaseUrl}tabs/free_gifts/fgift_008.png`;
  const giftSidewalkUrl = `${options.assetsBaseUrl}tabs/free_gifts/fgift_017.png`;
  const giftBriefcaseUrl = `${options.assetsBaseUrl}tabs/free_gifts/fgift_019.png`;
  const giftBalloonsUrl = `${options.assetsBaseUrl}tabs/free_gifts/fgift_034.png`;
  const localUserName = escapeHtml(options.localUserName);
  const localCityName = escapeHtml(options.localCityName);
  const localProfilePictureUrl = escapeAttribute(options.localProfilePictureUrl);
  const localProfileBootstrapJson = escapeScriptJson(JSON.stringify({
    userName: options.localUserName,
    cityName: options.localCityName,
    profilePictureUrl: options.localProfilePictureUrl
  }));

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

      .panel_notice {
        color: #4b6f8a;
        font-size: 13px;
        line-height: 1.45;
        margin-bottom: 14px;
      }

      .panel_box {
        margin: 12px 0;
        padding: 14px 16px;
        border: 1px solid #d3ebfb;
        border-radius: 12px;
        background: linear-gradient(180deg, #ffffff 0%, #eef8ff 100%);
      }

      .panel_actions {
        margin-top: 12px;
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

      .panel_button.disabled {
        opacity: 0.72;
        cursor: default;
      }

      #gifts,
      #neighbors,
      #dcsw {
        display: none;
        visibility: hidden;
        z-index: 1000;
      }

      #gifts_body h1,
      #nb_body h1,
      #dcsw_body h1 {
        margin: 0 0 12px;
        font-size: 22px;
        font-family: ChallengeBoldLETRegular, Verdana, Arial, sans-serif;
      }

      #gifts_body p,
      #nb_body p,
      #dcsw_body p {
        text-indent: 0;
      }

      #dcsw_body,
      #nb_body {
        max-height: 360px;
      }

      #gifts_body {
        max-height: 430px;
      }

      #gifts_body .gifts_inner {
        margin-top: 12px;
      }

      #gifts_body .gift-block {
        margin-right: 8px;
      }

      #gifts_body .gift-block span,
      #gifts_body .gift-block p {
        text-indent: 0;
      }

      .offline_row {
        padding: 10px 0;
        border-bottom: 1px solid #e6eef5;
      }

      .offline_row:last-child {
        border-bottom: 0;
      }

      .offline_title {
        color: #1d669f;
        font-weight: bold;
        margin-bottom: 4px;
      }

      .offline_meta {
        color: #6e8394;
        font-size: 11px;
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
          <object id="flash" name="flash" type="application/x-shockwave-flash" data="/client/Dollars.private.swf">
            <param name="movie" value="/client/Dollars.private.swf" />
            <param name="quality" value="high" />
            <param name="pluginspage" value="https://www.macromedia.com/go/getflashplayer" />
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

      <div id="neighbors" class="tab-content rounded-shadow">
        <span class="nb_close" id="neighbors_close">&nbsp;</span>
        <div id="nb_header"></div>
        <div class="nb_outer">
          <div id="nb_body">
            <h1 class="blue-text">My Neighbors</h1>
            <p class="panel_notice">The original neighbors panel depended on Facebook friends, requests, and Digital Chocolate backend calls. This local build keeps the original wrapper layout, but runs in single-player mode.</p>
            <div class="panel_box">
              <div class="offline_row">
                <div class="offline_title">Neighbors are offline</div>
                <div class="offline_meta">Local mode returns an empty neighbor list so the city remains playable without Facebook integration.</div>
              </div>
              <div class="offline_row">
                <div class="offline_title">Advisor and missions still work</div>
                <div class="offline_meta">The world, missions, tutorial, and city save continue to use the local backend.</div>
              </div>
            </div>
            <div class="panel_actions">
              <span class="panel_button" id="neighbors_back_button">Back to Game</span>
            </div>
          </div>
          <div id="nb_footer"></div>
        </div>
      </div>

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
              <div style="display:inline-block;width:360px;vertical-align:top;padding-top:18px;">
                <p class="blue-text"><span id="username">${localUserName}</span> and other friends would normally appear here through Facebook requests.</p>
                <br />
                <p class="blue-text">The original tab shell is preserved, but gifting is disabled in offline single-player mode.</p>
              </div>
              <div style="display:inline-block;vertical-align:text-bottom;width:150px;height:60px;">
                <p class="uiButton uiButtonConfirm freeGiftButton panel_button disabled" id="suggested_gift">Send Gift</p>
              </div>
            </div>

            <h1 class="blue-text">Choose a gift below</h1>
            <div id="gifts_feedback" class="blue-text" style="display:block; text-align:center; margin-bottom:10px;">This feature is currently offline in the private server.</div>
            <div class="gifts_inner">
              <div class="gift-block" style="background-image: url('${options.assetsBaseUrl}tabs/free_gifts/fgift_openBox.png')">
                <div class="blue-text freeGiftText"><span>Mystery Briefcase</span></div>
                <img src="${giftMysteryUrl}" class="unlocked-image" alt="" />
                <p><span class="blue-text lockedGiftText">Offline</span></p>
                <span class="uiButton uiButtonConfirm freeGiftButton panel_button disabled">Send Gift</span>
              </div>
              <div class="gift-block" style="background-image: url('${options.assetsBaseUrl}tabs/free_gifts/fgift_place.png')">
                <div class="blue-text freeGiftText"><span>Sidewalk</span></div>
                <img src="${giftSidewalkUrl}" class="unlocked-image" alt="" />
                <p><span class="blue-text lockedGiftText">Offline</span></p>
                <span class="uiButton uiButtonConfirm freeGiftButton panel_button disabled">Send Gift</span>
              </div>
              <div class="gift-block" style="background-image: url('${options.assetsBaseUrl}tabs/free_gifts/fgift_openBox.png')">
                <div class="blue-text freeGiftText"><span>Mystery Safe</span></div>
                <img src="${giftBriefcaseUrl}" class="unlocked-image" alt="" />
                <p><span class="blue-text lockedGiftText">Offline</span></p>
                <span class="uiButton uiButtonConfirm freeGiftButton panel_button disabled">Send Gift</span>
              </div>
              <div class="gift-block" style="background-image: url('${options.assetsBaseUrl}tabs/free_gifts/fgift_place.png')">
                <div class="blue-text freeGiftText"><span>New Year Balloons</span></div>
                <img src="${giftBalloonsUrl}" class="unlocked-image" alt="" />
                <p><span class="blue-text lockedGiftText">Offline</span></p>
                <span class="uiButton uiButtonConfirm freeGiftButton panel_button disabled">Send Gift</span>
              </div>
            </div>
          </div>
          <div id="gifts_footer"></div>
        </div>
      </div>

      <div id="dcsw" class="tab-content rounded-shadow">
        <span class="dcsw_close" id="dcsw_close">&nbsp;</span>
        <div id="dcsw_header"></div>
        <div class="dcsw_outer">
          <div id="dcsw_body">
            <h1 class="blue-text">Messages</h1>
            <p class="panel_notice">This panel originally hosted the Digital Chocolate Social Wall. The local server keeps the same wrapper area, but replaces it with a static offline view.</p>
            <div class="offline_row">
              <div class="offline_title">No Facebook requests</div>
              <div class="offline_meta">Gift requests, neighbor invites, and the old social wall are disabled offline. Visiting NPC cities and upgrading their rent buildings is supported locally.</div>
            </div>
            <div class="offline_row">
              <div class="offline_title">Game state is still local and persistent</div>
              <div class="offline_meta">World loading, tutorial progress, missions, and item placement continue to save to the local SQLite backend.</div>
            </div>
            <div class="offline_row">
              <div class="offline_title">Original wrapper calls stay mapped</div>
              <div class="offline_meta">The SWF can still call the original wrapper task names without crashing, even though the old social flows are disabled.</div>
            </div>
            <div class="panel_actions">
              <span class="panel_button" id="messages_back_button">Back to Game</span>
            </div>
          </div>
          <div id="dcsw_footer"></div>
        </div>
      </div>

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
          Millionaire City v.${GAME_VERSION}, Copyright &copy; Digital Chocolate 2010. All Rights Reserved
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
      var LOCAL_PROFILE_SETTINGS_STORAGE_KEY = "mcity.localProfileSettingsVisible";
      var tasksBuffer = [];

      function getMovie(name) {
        return document[name] || document.getElementById(name) || window[name] || null;
      }

      function setStatus(title, text, className) {
        if (window.console && typeof window.console.debug === "function") {
          window.console.debug("[mcity] " + title + ": " + text);
        }
      }

      function notify(text, className) {
        setStatus("Private Server ${GAME_VERSION}", text, className || "");
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

      function privateServerUnavailable(task) {
        notify("Offline mode: " + task + " is disabled.", "status-warn");
        sendTask_to_flash("Private server: " + task + " is disabled.");
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
        curtain.style.height = document.documentElement.scrollHeight + "px";
        curtain.style.width = "100%";
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
          notify("Free Gifts is offline in local mode.", "status-warn");
          openPanel("gifts", id);
          return;
        }
        if (id === "labelFor_neighbors") {
          notify("Neighbors panel is offline in local mode.", "status-warn");
          openPanel("neighbors", id);
          return;
        }
        if (id === "labelFor_dcsw") {
          notify("Messages panel is offline in local mode.", "status-warn");
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
        notify("Gift wrapper synced to level " + level + ".", "status-ok");
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

      function launchFacebookRequest() {
        privateServerUnavailable("fbRequest");
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
        notify("Fan status enabled in private-server mode.", "status-ok");
        sendTask_to_flash("messageFanPopupClosed");
      }

      function launchFacebookCredits() {
        sendTask_to_flash("messageResponseFacebookCredits:1");
        notify("Purchase completed in private-server free mode.", "status-ok");
      }

      function launchGetFBCreditsBalance() {
        sendTask_to_flash("fbcreditsCurrentBalance:0:0");
      }

      function showFacebox() {
        privateServerUnavailable("showFacebox");
      }

      function fedPayment() {
        sendTask_to_flash("messageResponseFacebookCredits:1");
        notify("Purchase completed in private-server free mode.", "status-ok");
      }

      function showCRM() {
        privateServerUnavailable("showCRM");
      }

      function launchBookmark() {
        notify("Bookmark flow is unavailable in local mode.", "status-warn");
      }

      function showGamePopup() {
        notify("Popup flow is unavailable in local mode.", "status-warn");
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
          var openUrlPayload = parsePayload(data);
          if (openUrlPayload.url) {
            window.open(openUrlPayload.url, "_blank", "noopener");
          } else {
            privateServerUnavailable("openURL");
          }
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
          notify("Flash bridge ready.", "status-ok");
          pushInitialLocalProfileToFlash();
          sendDelayedTaskToFlash();
          return;
        }
        if (task === TASKS.SEND_LEVEL) {
          var levelData = parsePayload(data);
          unlockFreeGifts(levelData.level || 0);
          return;
        }
        notify("Flash task: " + task, "status-ok");
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
      document.getElementById("neighbors_close").addEventListener("click", closeGiftTab);
      document.getElementById("dcsw_close").addEventListener("click", closeGiftTab);
      document.getElementById("neighbors_back_button").addEventListener("click", closeGiftTab);
      document.getElementById("messages_back_button").addEventListener("click", closeGiftTab);

      bindTabHover();
      setLocalProfileSettingsVisible(getLocalProfileSettingsVisible());
      bindLocalProfileSettings();
      bindLocalResourceSettings();
      setInterval(sendDelayedTaskToFlash, 1000);
      showGameOnly();
      setTimeout(function() {
        notify("Launcher ready at ${options.appUrl}", "status-ok");
      }, 50);
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
