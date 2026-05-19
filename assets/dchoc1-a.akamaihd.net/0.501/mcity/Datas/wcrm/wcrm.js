function get_environment() {
    if (typeof(wcrmEnvironment) !== "undefined") {
	return wcrmEnvironment;
    } else {
	return 0;
    }
}

function get_project_id() {
    if (typeof(wcrmProjectId) !== "undefined") {
	return wcrmProjectId;
    } else {
	return 1;
    }
}

function get_server_url() {
    if (typeof(wcrmServerURL) !== "undefined") {
	return wcrmServerURL;
    } else {
	return "http://crm.digitalchocolate.com";
    }
}

function get_fb_id() {
    if (typeof(wcrmFbUserId) !== "undefined") {
	return wcrmFbUserId;
    } else {
	return "";
    }
}

function get_user_level() {
    if (typeof(wcrmUserLevel) !== "undefined") {
	return wcrmUserLevel;
    } else {
	return 1;
    }
}

function get_user_src() {
    if (typeof(wcrmSrc) !== "undefined") {
	return wcrmSrc;
    } else {
	return "";
    }
}

var SERVER = "http://crm.digitalchocolate.com";
var WCRM_GATEWAY = "/wcrm_gateway";
var gPromotionPoint = 0;
var gProductId = 0;
var gMsgId = 0;
var gTimerId;
var gServerCalled = 0;

/**
 *wcrm_track_event
 *Tracks a custom WCRM event
 *@param group is the event group name (e.g. SCRM)
 *@param event is the event name (e.g. Bookmark, Fanbox)
 *@param label is the event action label (e.g. Popup Clicked)
 *@param params is an Object that can hold several parameters (e.g. is_fan, other_user_id)
 *@param logScrm optional, set to false to stop loging into SCRM
 *@param logGa optional, set to false to stop loging into Google Analytics
 */
function wcrm_track_event(group, event, label, params_arg, logScrm, logGa)
{
    var existsBookmarked = false;
    var existsFan = false;
    var existsFriendsTotal = false;
    var existsAppFriendsTotal = false;
    var params = (typeof params_arg == 'undefined') ? {} : params_arg;

    var url = get_server_url()+"/event/track?fb_user_id="+get_fb_id()+"&event="+event+"&group="+group+"&label="+label+"&env="+get_environment()+"&project_id="+get_project_id();//Duplicated vars in params: +"&level="+get_user_level()+"&src="+get_user_src();
    for (var param in params) {
        if (param == "other_user_id") {
            url += "&other_user_id="+params[param];
        } else if (param == "category") {
            url += "&category="+params[param];
        } else if (param == "p1") {
            url += "&p1="+params[param];
        } else if (param == "p2") {
            url += "&p2="+params[param];
        } else if (param == "p3") {
            url += "&p3="+params[param];
        } else if (param == "p4") {
            url += "&p4="+params[param];
        } else if (param == "p5") {
            url += "&p5="+params[param];
        } else if (param == "parent_event_id") {
            url += "&parent_event_id="+params[param];
        } else if (param == "level") {
            url += "&level="+params[param];
        } else if (param == "resource_1_delta") {
            url += "&resource_1_delta="+params[param];
        } else if (param == "resource_1_balance") {
            url += "&resource_1_balance="+params[param];
        } else if (param == "resource_1_total") {
            url += "&game_currency_delta="+params[param];
        } else if (param == "game_currency_delta") {
            url += "&game_currency_delta="+params[param];
        } else if (param == "game_currency_balance") {
            url += "&game_currency_balance="+params[param];
        } else if (param == "game_currency_total") {
            url += "&game_currency_total="+params[param];
        } else if (param == "paid_currency_delta") {
            url += "&paid_currency_delta="+params[param];
        } else if (param == "paid_currency_balance") {
            url += "&paid_currency_balance="+params[param];
        } else if (param == "paid_currency_total") {
            url += "&paid_currency_total="+params[param];
        } else if (param == "real_currency_delta") {
            url += "&real_currency_delta="+params[param];
        } else if (param == "real_currency_balance") {
            url += "&real_currency_balance="+params[param];
        } else if (param == "real_currency_total") {
            url += "&real_currency_total="+params[param];
        } else if (param == "friends_total") {
            url += "&friends_total="+params[param];
	    existsFriendsTotal = true;
        } else if (param == "application_friends_total") {
            url += "&application_friends_total="+params[param];
	    existsAppFriendsTotal = true;
        } else if (param == "is_fan") {
            url += "&is_fan="+params[param];
	    existsFan = true;
        } else if (param == "is_bookmarked") {
            url += "&is_bookmarked="+params[param];
	    existsBookmarked = true;
        } else if (param == "unique_tracking_tag") {
            url += "&unique_tracking_tag="+params[param];
	} else if (param == "product") {
	    url += "&product="+params[param];
	} else if (param == "product_detail") {
	    url += "&product_detail="+params[param];
	} else if (param == "campaign_source") {
	    url += "&campaign_source="+params[param];
	} else if (param == "campaign_channel") {
	    url += "&campaign_channel="+params[param];
	} else if (param == "session_id") {
	    url += "&session_id="+params[param];
	} else if (param == "session_duration") {
	    url += "&session_duration="+params[param];
	} else if (param == "session_accumulated_time") {
	    url += "&session_accumulated_time="+params[param];
	} else if (param == "nanos_delta") {
	    url += "&nanos_delta="+params[param];
	} else if (param == "nanos_balance") {
	    url += "&nanos_balance="+params[param];
	} else if (param == "nanos_total") {
	    url += "&nanos_total="+params[param];
	} else if (param == "ref_uid") {
	    url += "&ref_uid="+params[param];
	} else if (param == "src") {
	    url += "&src="+params[param];
	} else if (param == "ref") {
	    url += "&ref="+params[param];
        } else {
            // An unsupported parameter
        }
    }

    if(!existsBookmarked && typeof(wcrmIsBookmarked) !== "undefined") {
	url += "&is_bookmarked="+wcrmIsBookmarked;
    }
    if(!existsFan && typeof(wcrmIsFan) !== "undefined") {
	url += "&is_fan="+wcrmIsFan;
    }
    if(!existsFriendsTotal && typeof(wcrmFriendsTotal) !== "undefined") {
	url += "&friends_total="+wcrmFriendsTotal;
    }
    if(!existsAppFriendsTotal && typeof(wcrmAppFriendsTotal) !== "undefined") {
	url += "&application_friends_total="+wcrmAppFriendsTotal;
    }

    //Set default values of optional parameters
    if(typeof(logScrm) === "undefined"){
	logScrm = true;
    }
    if(typeof(logGa) === "undefined"){
	logGa = false;
    }

    //log to SCRM
    if(logScrm == true) {
        //deprecated: crossdomain incompatible
	//$.get(url);
        var i = new Image(1,1);
        i.src = url;
    }
    //log to GA
    if(logGa == true) {
	//pageTracker must be a valid GA object!
        if(typeof(_gaq)!=="undefined")
        //if(typeof(pageTracker)!=="undefined")
        {
            if(typeof(wcrmIsFan)!=="undefined"){
            	_gaq.push(['_setCustomVar', 1, 'Is Fan', wcrmIsFan, 2]);
                //pageTracker._setCustomVar(1,'Is Fan', wcrmIsFan, 2);
            }
            if(typeof(wcrmIsBookmarked)!=="undefined"){
            	_gaq.push(['_setCustomVar', 2, 'Is Bookmarked', wcrmIsBookmarked, 2]);
                //pageTracker._setCustomVar(2,'Is Bookmarked', wcrmIsBookmarked, 2);
            }
            if(typeof(wcrmFriendsTotal)!=="undefined"){
            	_gaq.push(['_setCustomVar', 3, 'All Friends', wcrmFriendsTotal, 2]);
                //pageTracker._setCustomVar(3,'All Friends', wcrmFriendsTotal, 2);
            }
            if(typeof(wcrmAppFriendsTotal)!=="undefined"){
            	_gaq.push(['_setCustomVar', 4, 'App Friend', wcrmAppFriendsTotal, 2]);
                //pageTracker._setCustomVar(4,'App Friends', wcrmAppFriendsTotal, 2);
            }
            _gaq.push(['_trackEvent', group, event, label]);
            //pageTracker._trackEvent(group, event, label, 0);
        }
    }
}
// The API ends

/*
function wcrm_page_view(promotion_point_id)
{
    var url = SERVER+"/event/page_view?id="+promotion_point_id+"&env="+get_environment();
    $.get(url);
}
*/

function wcrm_timer_launched(index) {
    var activeElementIndex = index;
    var newActiveElementIndex = index+1;

    var curElement = jQuery("#wcrm_hot_chocolate_message_" + activeElementIndex);
    var newElement = jQuery("#wcrm_hot_chocolate_message_" + newActiveElementIndex);

    while(newActiveElementIndex < 100)
    {
        if(newElement.hasClass('wcrm_hot_chocolate_message_hidden')) {
            break;
        }
        newActiveElementIndex++;
        newElement = jQuery("#wcrm_hot_chocolate_message_" + newActiveElementIndex);
    }

    //if could not find a new message, re-start the loop
    if(!newElement.hasClass('wcrm_hot_chocolate_message_hidden')) {
	newActiveElementIndex = 1;
	newElement = jQuery("#wcrm_hot_chocolate_message_1");
    }

	if (curElement !== null && curElement.hasClass('wcrm_hot_chocolate_message'))
	{
		curElement.addClass('wcrm_hot_chocolate_message_hidden');
		curElement.removeClass("wcrm_hot_chocolate_message");

		if (newElement !== null && newElement.hasClass('wcrm_hot_chocolate_message_hidden'))
		{
			newElement.removeClass('wcrm_hot_chocolate_message_hidden');
			newElement.addClass("wcrm_hot_chocolate_message");
		}
	}

    gTimerId = setTimeout('wcrm_timer_launched('+newActiveElementIndex+')', 10000);
}

function wcrm_stop_timer() {
	clearTimeout(gTimerId);
}

function wcrm_remove_message(index) {
	//TODO remove the message
	//wcrm_timer_launched(index);
}

jQuery("document").ready(function()
{
    if (true) {
        gTimerId = setTimeout('wcrm_timer_launched(1)', 10000);
    }
});

/**
* wcrm_popup_action
* performs a specific action (i.e. show or hide) on a game popup
* @param popupType can be: Popup or Reward
* @param id of the hot_chocolate product
* @param action can be "block" to show or "none" to hide the popup
*/
function wcrm_popup_action(popupType, id, action) {
	switch(popupType)
	{
		case 'Popup':
			var e = 'wcrm_popup_'+id;
			document.getElementById(e).style.display = action;
			break;
		case 'Reward':
			var e = 'wcrm_reward_'+id;
			document.getElementById(e).style.display = action;
			break;
		case 'Error':
			var e = 'wcrm_error_'+id;
			document.getElementById(e).style.display = action;
			break;
		default:
			//it MUST never get here
			alert('you called wcrm_popup_show with parameter: '+popupType+' which is not supported');
			return;
	}
	document.getElementById('wcrm_popup_background').style.display = action;
}

/**
* wcrm_popup_show
* shows the Game a specific popup dialog
* @param popupType can be: Popup,Reward or Error
* @param id of the hot_chocolate message
* @param event is a valid string object when triggered by the user (onClick), null otherwise.
* @param promotion_id is the DB id of the CBar promotion point
* @param product_id is the DB id of the CBar product
*/
function wcrm_popup_show(popupType, id, event, promotion_id, product_id) {
	//log only when being called from a user-triggered action
	if(event !== null) {
                var params = new Object;
		params.p1 = promotion_id
		params.p2 = product_id;
		wcrm_track_event('SCRM',event,'Hot Chocolate Clicked',params);
	}
	wcrm_popup_action(popupType, id, 'block');

	//stop the timer
	//wcrm_stop_timer();
}

/**
* wcrm_popup_hide
* shows the Game a specific popup dialog
* @param popupType can be: Popup,Reward or Error
* @param id of the hot_chocolate message
* @param event is a valid string object when triggered by the user (onClick), null otherwise.
* @param promotion_id is the DB id of the CBar promotion point
* @param product_id is the DB id of the CBar product
*/
function wcrm_popup_hide(popupType, id, event, promotion_id, product_id) {
	//log only when being called from a user-triggered action
	if(event !== null) {
                var params = new Object;
		params.p1 = promotion_id
		params.p2 = product_id;
		wcrm_track_event('SCRM',event,popupType+' Closed',params);
		//wcrm_timer_launched(id);
	}
	wcrm_popup_action(popupType, id, 'none');

	//reload iframe after closing a reward
	if(popupType == 'Reward') {
	    location.reload(true);
	}
}

/**
* wcrm_show_fb_bookmark
* shows the facebook bookmark iframe dialog
* and calls a callback function upon closing.
* @param id of the hot_chocolate message
* @param promotion_id is the DB id of the CBar promotion point
* @param product_id is the DB id of the CBar product
*/
function wcrm_show_fb_bookmark(id, promotion_id, product_id) {
	//set the globals needed to make the server request inside the callback
	gMsgId = id;
	gPromotionPoint = promotion_id;
	gProductId = product_id;

        var params = new Object;
	params.p1 = gPromotionPoint;
	params.p2 = gProductId;
	wcrm_track_event('SCRM','Bookmark','Clicked',params);

	FB.Connect.showBookmarkDialog(wcrm_bookmark_callback);
}

/**
* wcrm_bookmark_callback
* This function gets called whenever the facebook iframe dialog is closed.
*/
function wcrm_bookmark_callback() {
	var URL = WCRM_GATEWAY + "/reward?promotion_point_id="+gPromotionPoint+"&product_id="+gProductId;
	jQuery.get(URL, function(data,status) {
		wcrm_get_reward(data, status);
	});
}

/**
* wcrm_register_email
* Registers user's email.
* @param id of the hot_chocolate message
* @param promotion_id is the DB id of the CBar promotion point
* @param product_id is the DB id of the CBar product
*/
function wcrm_process_email(id, promotion_id, product_id) {
	//set the globals needed to make the server request inside the callback
	gMsgId = id;
	gPromotionPoint = promotion_id;
	gProductId = product_id;

        var params = new Object;
	params.p1 = gPromotionPoint;
	params.p2 = gProductId;
	wcrm_track_event('SCRM','Register','Button Clicked',params);

	//TODO change this shit
	email = document.getElementById('wcrm_popup_email_textbox').value;

	//validate user's input
//	if(wcrm_validate_email(email) == true)
	if(wcrm_validate_input(email) == true)
	{
		//hide any error message
		document.getElementById('email_error_msg').style.display = 'none';

		//disable onclick method to avoid dupes in register (i.e. this function won't be called twice)
		//document.getElementById('wcrm_process_email_link').onclick = function(){};

		//email parsed! try to register in server
		if(gServerCalled == 0) {
		    gServerCalled = 1;
		    var URL = WCRM_GATEWAY + "/register?email="+email;
		    jQuery.get(URL, function(data,status) {
			    wcrm_register_email(data, status);
		    });
		}
	}
	else {
		//show error message
		document.getElementById('email_error_msg').style.display = 'inline';
	}
}

/**
* wcrm_fanbox_clicked
* logs the correspondent action
* @param id of the hot_chocolate message
* @param promotion_id is the DB id of the CBar promotion point
* @param product_id is the DB id of the CBar product
*/
function wcrm_fanbox_clicked(id, promotion_id, product_id) {
	//set the globals needed to make the server request inside the callback
	gMsgId = id;
	gPromotionPoint = promotion_id;
	gProductId = product_id;

        var params = new Object;
	params.p1 = promotion_id
        params.p2 = product_id;
	wcrm_track_event('SCRM','Become a Fan','Button Clicked',params);

        var URL = WCRM_GATEWAY + "/reward?promotion_point_id="+gPromotionPoint+"&product_id="+gProductId;
	jQuery.get(URL, function(data,status) {
		wcrm_get_reward(data, status);
	});
}

/**
* wcrm_get_reward
* Call the server and try to get a reward for a specified action
* @param xml the response data in xml format
* @param status the status text of the call
*/
function wcrm_get_reward(xml, status) {
        var params;
	if(status == 'success')
	{
		//grab the instance of 'status' tag from xml response
		//this doesn't work under fucking IE
		//r = $('status', xml).eq(0).text();
		r = xml.substr(xml.indexOf('</status>')-1,1);

		if(r == 0) {
			jQuery('reward', xml).each( function() {
				//TODO build reward dialog with this info??
				id = jQuery(this).find('id').text();
				p1 = jQuery(this).find('param_1').text();
				p2 = jQuery(this).find('param_2').text();
				p3 = jQuery(this).find('param_3').text();
				p4 = jQuery(this).find('param_4').text();
				p5 = jQuery(this).find('param_5').text();
			});

                        params = new Object;
			params.p1 = gPromotionPoint;
                        params.p2 = gProductId;
                        wcrm_track_event('SCRM','Reward','Confirmed',params);

			wcrm_popup_hide('Popup', gMsgId, null);
			wcrm_popup_show('Reward', gMsgId, null);
			//wcrm_remove_msg(gMsgId);
		}
		else if(r == 1) {
		    //reward not given
                        params = new Object;
			params.p1 = gPromotionPoint;
                        params.p2 = gProductId;
                        wcrm_track_event('SCRM','Reward','Cancelled',params);

			wcrm_popup_hide('Popup', gMsgId, null);
			wcrm_popup_show('Error', gMsgId, null);
			//wcrm_timer_launched(gMsgId);
		}
		else {
			//error from server, just close the popups
                        params = new Object;
			params.p1 = gPromotionPoint;
                        params.p2 = gProductId;
                        wcrm_track_event('SCRM','Reward','Cancelled',params);

			wcrm_popup_hide('Popup', gMsgId, null);
		}
	}
	else {
		//error from server, just close the popups
                params = new Object;
		params.p1 = gPromotionPoint;
                params.p2 = gProductId;
                wcrm_track_event('SCRM','Reward','Error',params);

		wcrm_popup_hide('Popup', gMsgId, null);
		//wcrm_timer_launched(gMsgId);
	}
	gServerCalled=0;
}

/**
* wcrm_validate_email
* Validates an e-mail address using REGEX
* @param email the address to be validated
* @return true on success, false otherwise
*/
function wcrm_validate_email(email)  {
   var regex = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
   if(regex.test(email) == true) {
      return true;
   }
   return false;
}

function wcrm_validate_input(email) {
   if(wcrm_validate_email(email) == false){
       document.getElementById('email_error_msg').innerHTML = 'The e-mail you entered is invalid';
       return false;
   }
   if(document.getElementById('tos_ok').checked == false){
       document.getElementById('email_error_msg').innerHTML = 'You must accept the terms';
       return false;
   }
   return true;
}

/**
* wcrm_register_email
* Call the server and try to register a user e-mail
* @param xml the response data in xml format
* @param status the status text of the call
*/
function wcrm_register_email(xml, status) {
        var params;
	if(status == 'success')
	{
		//grab the instance of 'status' tag from xml response
		//this doesn't work under fucking IE
		//r = $('status',xml).eq(0).text();
		r = xml.substr(xml.indexOf('</status>')-1,1);

		if(r == 0)  {
                    //registering email was OK, get the reward
                    var URL = WCRM_GATEWAY + "/reward?promotion_point_id="+gPromotionPoint+"&product_id="+gProductId;
                    jQuery.get(URL, function(data,status) {
                            wcrm_get_reward(data, status);
                    });
		}
		else {
			//Already registered or problem registering
                        params = new Object;
			params.p1 = gPromotionPoint;
                        params.p2 = gProductId;
                        wcrm_track_event('SCRM','Register','Already Registered',params);

			wcrm_popup_hide('Popup', gMsgId, null);
			wcrm_popup_show('Error', gMsgId, null);
			gServerCalled=0;
		}
	}
	else {
                params = new Object;
		params.p1 = gPromotionPoint;
                params.p2 = gProductId;
                wcrm_track_event('SCRM','Register','Error',params);

		wcrm_popup_hide('Popup', gMsgId, null);
		//wcrm_timer_launched(gMsgId);
		gServerCalled=0;
	}
}
