DC_SocialWall_disabled = false; // flag on/off social wall and tabs

ACTION_PARTNER_REQUEST = 'partnerRequest';
ACTION_NEIGHBOR_REQUEST = 'neighborRequest';
ACTION_COLLECTIBLE = 'acceptGift';
ACTION_GIFT = 'sendFreeGift';
ACTION_CREW = 'addCrewToItem';

function removeCurtains(){
	jQuery(".curtain").each(function(index){
			jQuery(this).remove();
		});
}

function DC_SocialWall( element_id, label_id, config ) {

var self=this;
var started = false;
var uid = -1;
var hash = '';
DC_SocialWall.instance = self;
this.requests = [];
this.requestSigs = {};
this.config = config;
this.level_player = 1;

this.types = { 
    'all': {id:'all', tid:'DCSW_ALL_MESSAGES',total:0, 'default':true}, 
    ACTION_PARTNER_REQUEST: {id:ACTION_PARTNER_REQUEST, tid:'DCSW_BUSS_PARTNER_TAB', total:0 },
    ACTION_NEIGHBOR_REQUEST: {id:ACTION_NEIGHBOR_REQUEST, tid:'DCSW_NEIGHBOR_TAB', total:0 },
    ACTION_COLLECTIBLE: {id:ACTION_COLLECTIBLE, tid:'DCSW_COLLECTIBLES_TAB', total:0 },
    ACTION_GIFT: {id:ACTION_GIFT, tid:'DCSW_GIFT_TAB', total:0 },
	ACTION_CREW: {id:ACTION_CREW, tid:'DCSW_CREW_TAB', total:0}
};

this.element_id = element_id;
this.label_id = label_id;

this.init=function() {
    if( DC_SocialWall_disabled ) return false;

    self.element = document.getElementById(self.element_id);
    self.label = document.getElementById(self.label_id);
    var initial_str = "<span class='dcsw_close'>&nbsp;</span><div id='dcsw_header'></div>";
    initial_str += "<div class='dcsw_outer'><div id='dcsw_tabs'></div></div>";
    initial_str += "<div class='dcsw_outer'><div id='dcsw_body'></div></div>";
    initial_str += "<div id='dcsw_footer'></div>";
    self.element.innerHTML = initial_str;
    jQuery('.dcsw_close').click( self.closeEvent );
    //self.getAllRequests();
}

this.closeEvent=function(e){
    // simulate click on game tab
	SOCIAL_WALL_VISITED = true;
    clickOnTab( "labelFor_gameEmbed");
    removeCurtains();
    jQuery("#"+this.element_id).css("z-index","auto");
	clickOnTab( "labelFor_gameEmbed");
		
}

this.getNewRequests = function(id,hash, showWall) { // called every minute
    if( jQuery("#dcsw").css('visibility') == 'visible') return false;

    self.uid = id;
    self.hash = hash;

	FB.api('/me/apprequests', function(responseFb){
        
		if( responseFb.data ) {
			if(responseFb.data.length > self.getTotalFor('all') )
			{
				self.getAllRequests(self.uid, self.hash, showWall);
			}
		} else {
			//console.log( responseFb );
		}
	});
}

this.getAllRequests = function(id, hash, showWall) {
	this.uid = id;
	this.hash = hash;
    jQuery.get('/dollar/AcceptFacebookRequest?message_center=1&action=request&ref_uid='+id+'&hash='+hash+'&rand='+(new Date().getTime()), 
		function(response){
			if(response) {
                if( typeof response != "object" ) response = jQuery.parseJSON(response);
				if( response.success != 1) return false;

				self.requestSigs = response.data;
			    FB.api('/me/apprequests', function(responseFb){
				    self.createRequestsInfoFromFb(responseFb, showWall);
				});
			}
		}, 
    "json");
}

this.actionSupported=function( action ){
    if( action == 'all') return false;

    for( type in this.types ){
        if( this.types[type].id == action) return true;
    }
    return false;
}

this.createRequestsInfoFromFb = function(responseFb, showWall) {
	if( responseFb.data ) {
		for(var i=0; i<responseFb.data.length; i++){
			var request = responseFb.data[i];
			try {
				//var data = request.data.evalJSON();
				var data = jQuery.parseJSON( request.data );
			} catch (e){
				//Invalid request: remove it
				FB.api("/"+request.id+"?method=DELETE");
				continue;
			}
			
			if( data.action == "partnerAdd") data.action="partnerRequest"; // TODO: backwards compatibility: arg
			if( data.action == "neighborAdd") data.action="neighborRequest"; // TODO: backwards compatibility: arg

			if( this.actionSupported( data.action ) ) {
				request.data = data;
                var signature = this.getSignature( request.id );
                if( signature == false && signature == "false" ){
                    // we dont have signature for this
                    continue;
                }
                var request = new DC_Request( request, signature, self.hash );
                this.addRequest( request );
			}
		}

        this.updateTotals();

        if( showWall==true && self.requests.length>0 && GIFTING_INTERSTITIAL_CLOSED) {
            clickOnTab("labelFor_dcsw");
        }
	} else {
		//console.log( responseFb );
	}
}

this.addRequest=function( request ){
    if( this.getRequest( request.getId() ) == false ){
        this.requests.push( request );
    } else {
        //console.log( "Request "+request+ " already exists");
    }
}

this.getSignature=function(request_id){
    for(var i=0; i< self.requestSigs.length; i++)
        if( self.requestSigs[i].id == request_id ) return self.requestSigs[i].sig;
    return false;
}

this.getRequest=function(id) {
    for(var i=0; i< self.requests.length; i++)
        if( self.requests[i].getId() == id ) return self.requests[i];

    return false;
}

this.removeRequestFromFB=function(request){
    FB.api("/"+request.getId()+"?method=DELETE");
}

this.removeRequest=function( request ) {
    for(var i=0; i< self.requests.length; i++)
        if( self.requests[i].getId() == request.getId() ) {
            self.requests.splice( i, 1);
            self.updateTotals();
            return true;
        }
    return false;
}

this.show=function(){
    var total = self.requests.length;

    if( total > 0 ) {
        self.drawTabs();
	    self.drawBody( 'all' );
    } else {
        // empty wall
        this.emptyWall();
    }
/*
    jQuery('body').prepend( "<div id='curtain_dcsw' class='curtain'/>" );
    jQuery("#curtain_dcsw" )
     .css({ "height":jQuery(document).height(), "width":"100%", "z-index":999} );
    jQuery( "#"+this.element_id ).css("z-index", 1000);
*/
}

this.emptyWall=function(){
   this.drawTabs();
   var el = document.getElementById("dcsw_body");
   var output = "<h1 class='blue-text'>"+self.i18n("DCSW_EMPTY")+"</h1>";
   output+= "<ul>";
   
   output+= "<li class='row'>";
   output+= "<img src='"+config['ASSETS_PATH']+"/tabs/social_wall/general/gift_box_2.png'/>";
   output+= "<div class='request_mid_col'>"+
//               "<span class='green-text'>"+self.i18n( "TESTTEXT_1" )+"</span><br>"+
               "<span class='blue-text'>"+self.i18n( "DCSW_EMPTY_GIFTS" )+"</span>"+
               "</div>";
   output+= "<div class='request_right_col' style='margin-top: 20px;'>"+
            "<span id='sendFreeGifts' class='uiButton uiButtonConfirm uiButtonMedium accept-request-button'>"+
            self.i18n( "FGT_TITLE" )+"</span></div>";
   output+= "</li>";
   
   output+= "<li class='row'>";
   output+= "<img src='"+config['ASSETS_PATH']+"/tabs/social_wall/general/icon_partner.png'/>";
   output+= "<div class='request_mid_col'>"+
//               "<span class='green-text'>"+self.i18n( "TESTTEXT_3" )+"</span><br>"+
               "<span class='blue-text'>"+self.i18n( "DCSW_EMPTY_PARTNERS" )+"</span>"+
               "</div>";
   output+= "<div class='request_right_col'>"+
            "<span id='sendPartnerRequest' class='uiButton uiButtonConfirm uiButtonMedium accept-request-button'>"+
            self.i18n("DCSW_EMPTY_PARTNERS_BUTTON")+"</span></div>";
   output+= "</li>";

   output+= "</ul>";

   el.innerHTML = output;
   jQuery("#sendFreeGifts").click( function(){clickOnTab("labelFor_gifts")} );
   jQuery("#sendPartnerRequest").click( function(){
       launchFacebookRequest( {"action":"partnerRequest", "useNeighborList":"1"} );
   } );
}

this.updateTotals=function(){

    var globalTotal = 0;

    for( var i in self.types ){
        var type = self.types[i].id;
        var total= self.getTotalFor(type, true);
        if( type != 'all' )
            globalTotal+= total;

        var visibility = (total > 0)? "inherit" : "hidden";
        jQuery( "#"+type+"_total" ).html( total ).css("visibility",visibility);
    }
    
    self.setTotalLabel( globalTotal );
}

this.getTotalFor=function( type, only_new ){
    if( !only_new ) only_new = false;
    var total = 0;

    for(var i=0; i< self.requests.length; i++){
        var request = self.requests[i];
        if( request.getAction() == type || type=='all' ) {
            if( only_new ) {
                if( request.isNew() ) total++;
            } else total++;
        }
    }
    return total;
}

this.getTidForAction=function( action ){
    for(var i in self.types){
        var type = self.types[i];
        if ( type.id == action ) return type.tid;
    }
    return action;
}

this.setTotalLabel=function( total ){
    self.label.innerHTML = total;
    if( total > 0 ) {
        jQuery(self.label).css("visibility","visible");
    } else {
        jQuery(self.label).css("visibility","hidden");
    }
}

this.drawBody=function( type ){
    var output = "";

    if( type=="all") {
        for( var i in self.types ) {
            //var total = self.typesById[self.types[i].id].total;
            var total = self.getTotalFor( self.types[i].id );
            if( total < 1 ) continue;
            if( self.types[i].id != "all" )
                output += self.drawRequestsType( self.types[i].id );
        }
    } else 
        output += self.drawRequestsType( type );

    var el = document.getElementById("dcsw_body");
    el.innerHTML = output;
    jQuery(".accept-request-button").click( self.accept );
    jQuery(".giftback-request-button").click( self.sendItBack );
    jQuery(".dcsw_requests_separator").click( self.moreClicked );
    jQuery(".dcsw_ignore_button").click( self.ignore );
}

this.drawRequestsType=function( type ) {
    var limit = 3;
    var count = 0;
    var output = "<ul>";
    var invisible_class = "";

    if( ! this.actionSupported( type ) ) return;

    output += "<div class='dcsw_type_header'>"+self.getTotalFor(type)+" "+ self.i18n( self.getTidForAction(type) )+"</div>";
    
    for( var i=0; i< self.requests.length; i++ ) {
        var request = self.requests[i];
        if(type!=request.getAction() ) continue;

        if( count == limit ) {
            invisible_class = "dcsw_hidden_request";
            var more = self.getTotalFor(type) - count;
            output += "<div class='dcsw_requests_separator'>"+more+" More...</div>";
        }

        var html = request.render( self.config );
        var extra_class = '';
        extra_class += (request.ignored)?"ignored-request ":"";
        extra_class += (request.accepted)?"accepted-request ":"";

        output += "<li id='request_"+request.getId()+"' class='request "+invisible_class+" "+extra_class+"'>"+html+"</li>";

        if( request.isNew() ) count++;
    }
    output += "</ul>";
    return output;
}

this.drawTabs=function() {
    var tabs = document.getElementById("dcsw_tabs");
	tabs.innerHTML = "";
    for( var i in self.types ){
        var selected = (self.types[i]['default']) ? self.types[i]['default']:false;
        
        var total = this.getTotalFor( self.types[i].id , true );
        if( total > 0 ) 
            self.addTab( self.types[i].id , self.types[i].tid, selected );
    }
}

this.addTab=function( id, tid, selected ) {
    var tabs = document.getElementById("dcsw_tabs");
    var selected_class="";
    if( selected == false ) selected_class=" dcsw_tab_unselected";

    var total = this.getTotalFor(id);
    var ev = 'DC_SocialWall.instance.tabSelected(this)';
    var str = "<span id='"+id+"' class='dcsw_tab "+selected_class+"' onclick='"+ev+"'>"+i18n.get( tid )+"</span><span id='"+id+"_total' class='dcsw_tab_counter' style='"+((total==0)?"visibility:hidden":"")+"'>"+total+"</span>";
    tabs.innerHTML += str;
}

this.tabSelected=function( element ) {
    jQuery('.dcsw_tab').addClass("dcsw_tab_unselected");
    jQuery(element).removeClass("dcsw_tab_unselected");
    self.drawBody( element.id );
}

this.accept=function(ev) {
    var requestID = jQuery(this).attr("id").split("_").pop();
    var requestURL= jQuery(this).attr("href");

    var request = self.getRequest( requestID );
    var action = request.getAction();
	
    // hide the request first to avoid multiple clicks
    request.disable();
	if(request.getSignature() == false)
	{
        request.showServerError(response);
        self.removeRequest( request );
		return false;
	}
    jQuery.get( requestURL, function(response){
        if(response == '1' || response == '2' ) {
            // success
			var task;

            if(action == ACTION_PARTNER_REQUEST ) {
                task = "messageBecomePartner:"+request.getId();
                self.removeRequest( request );
                // notify CRM
                if( typeof notifyWCRM == 'function' )
		            notifyWCRM("Social", "FB Invite", "Clicked", { unique_tracking_tag : requestID } );
            }
			else 
            if(action == ACTION_NEIGHBOR_REQUEST) {
                
				task = "messageAddNeighbor";
                self.removeRequest( request );
                DCNB.refresh(); // refresh the neighbors tab
                // notify CRM
                if( typeof notifyWCRM == 'function' )
		            notifyWCRM("Social", "FB Invite", "Clicked", { unique_tracking_tag : requestID } );
			}
			else 
            if(action == ACTION_COLLECTIBLE) {
                
				task = "messageAcceptCollectible:"+request.getSku();
                self.removeRequest( request );
                // notify CRM
                if( typeof notifyWCRM == 'function' )
		            notifyWCRM("Social", "FB Gift", "Clicked", { 
                        product_detail:request.getSku(), 
                        unique_tracking_tag : requestID, 
                        product:'Collectible' } );
			}
			else 
            if(action == ACTION_CREW) {
			
                self.removeRequest( request );
                // notify CRM
                if( typeof notifyWCRM == 'function' )
		            notifyWCRM("Social", "FB Crew Invite", "Clicked", {
                        unique_tracking_tag : requestID } );
			}
			else 
            if(action == ACTION_GIFT ) {
				task = "messageFreeGift:"+request.getSku();
				jQuery( "#ignore_"+requestID ).remove();
				jQuery( "#accept_"+requestID+" > span.dcsw_accept_text" ).html( i18n.get('DCSW_SENDITBACK') );
					
                if( response == '1' ) {
                    // Gift accepted and can send gift back
                    request.gift_back = true;
                    var copy = jQuery( "#accept_"+requestID ).clone();
                    jQuery( "#accept_"+requestID ).replaceWith( copy );

                    jQuery( "#accept_"+requestID )
                        .removeClass( "accept-request-button" )
					    .addClass("giftback-request-button")
                        .css('visibility','inherit')
                        .click( self.sendItBack  );
                    self.updateTotals();
                }
				else if( response == '2' ) {
                    // Gift accepted but cant send gift back (redirected to gifts window)
				    jQuery( "#accept_"+requestID ).unbind("click").css('visibility','inherit').click( function(){
							clickOnTab("labelFor_gifts")
				    } );
                    self.removeRequest( request );
				}
                
                // notify CRM
                if( typeof notifyWCRM == 'function' )
    		        notifyWCRM("Social", "FB Gift", "Clicked", { 
                        product_detail:request.getSku(), 
                        unique_tracking_tag : requestID, 
                        product:'Free Gift' } );
			}
            request.accept();
            sendTask_to_flash( task );

        } else {
            // UNEXPECTED ERROR
            request.showServerError(response);
            self.removeRequest( request );
            self.removeRequestFromFB( request );
        }
    } , "HTML" );
    return false;
}

this.sendItBack=function(e){
    e.preventDefault();
	var requestID = jQuery(this).attr("id").split("_").pop();
    var request = self.getRequest( requestID );
    var level_player = parseInt(self.level_player);
    var level_required = parseInt( jQuery( '#'+request.getSku() ).attr('level') );
	
	if( level_player >= level_required || request.gift_back == true ) {
	    if( typeof self.config['GIFT_BACK_CALLBACK'] == "function" ) {
		    self.config['GIFT_BACK_CALLBACK'].call( this, {"action":ACTION_GIFT, "sku":request.getSku(), "tid":request.getTID(), "gift_back":"1"}, {"to":request.getFromId() } ); 
	    }
    } else {
		clickOnTab("labelFor_gifts");
    }

	jQuery( "#accept_"+requestID )
        .unbind()
        .css("visibility","hidden");

    self.removeRequest( request );
}

this.ignore=function( e ) {
    e.preventDefault();
    var ignore_url = jQuery(this).attr("href");
    var el_id = jQuery(this).attr("id");
    var parts = el_id.split("_");
    var requestID = parts[1];
    jQuery(this).parent().hide();
    jQuery(this).parent().parent().addClass("ignored-request");
    self.removeRequest( self.getRequest(requestID) );
    var request = self.getRequest( requestID );
    request.ignored=true;
    jQuery.get( ignore_url );
	return false;
}

this.moreClicked=function( e ){
    jQuery(this).hide().nextAll().removeClass('dcsw_hidden_request');
}

this.i18n=function( tid, params ) {
    return i18n.get( tid, params );
}

self.init();
}

/* REQUEST OBJECT *****************************************************/
function DC_Request( data, sig, hash){
    this._fb_request = data;
    this._signature = sig;
    this.hash = hash;

    // flags
    this.accepted = false;
    this.ignored = false;
    this.gift_back = false;
	
	//TODO:
	this.error = -1;
}
DC_Request.prototype.getId=function(){ return this._fb_request.id; }
DC_Request.prototype.getMessage=function(){ 
    if(this.getAction() == ACTION_GIFT && this.gift_back )
        return i18n.get('DCSW_GIFT_ACCEPTED', {'U': i18n.get( this.getTID() )});

    return this._fb_request.message; 
}
DC_Request.prototype.getFbRequest=function(){ return this._fb_request; }
DC_Request.prototype.getAction=function(){ return this._fb_request.data.action; }
DC_Request.prototype.getSku=function(){ return this._fb_request.data.sku; }
DC_Request.prototype.getTID=function(){ return this._fb_request.data.tid; }
DC_Request.prototype.getSignature=function(){ return this._signature; }
DC_Request.prototype.getFromName=function(){ return this._fb_request.from.name; }
DC_Request.prototype.getToId=function(){ return this._fb_request.to.id; }
DC_Request.prototype.getFromId=function(){ return this._fb_request.from.id; }
DC_Request.prototype.disable=function() {
    var id = this.getId();
    jQuery("#request_"+id+" .accept-request-button").css('visibility','hidden');
    jQuery("#request_"+id+" .dcsw_ignore_button").css('visibility','hidden');
}
DC_Request.prototype.showServerError=function(response) {
    var errorText = i18n.get("DCSW_ERROR");
	if(response == '3')
	{
		errorText = i18n.get("DCSW_GIFT_EXPIRED");
	}
	else if(response == '4')
	{
		errorText = 'Server internal error. Please reload the game and try again.';
	}
	else if(response == '5')
	{
		errorText = i18n.get("DCSW_CREW_EXPIRED");
	}
	else if(response == '6')
	{
		errorText = i18n.get("DCSW_CREW_ALREADY_FILLED");
	}
    var id = this.getId();
    jQuery("#request_"+id).removeClass( 'accepted-request' );
    jQuery("#request_"+id+" .request_mid_col").html( errorText ).removeClass("green-text").addClass("red-text");
    jQuery("#request_"+id+" .request_right_col").hide();
	this.error = response - '0';
}
DC_Request.prototype.accept=function() {
    this.accepted = true;

    if(this.getAction() == ACTION_PARTNER_REQUEST )
        accept_text = i18n.get('DCSW_BUSS_PARTNER_ACCEPTED', {'U':this.getFromName() } );
    else if(this.getAction() == ACTION_NEIGHBOR_REQUEST )
        accept_text = i18n.get('DCSW_NEIGHBOR_ACCEPTED', {'U':this.getFromName() } );
    else if(this.getAction() == ACTION_COLLECTIBLE )
        accept_text = i18n.get('DCSW_COLLECTIBLES_ACCEPTED');
    else if(this.getAction() == ACTION_GIFT )
	    accept_text = i18n.get('DCSW_GIFT_ACCEPTED', {'U': i18n.get( this.getTID() )});
    else if(this.getAction() == ACTION_CREW )
	    accept_text = i18n.get('DCSW_CREW_ACCEPTED', {'U': i18n.get( this.getTID() )});

    var id = this.getId();
	var hidden_gift = jQuery("#request_"+id+" .request_right_col .request-icon-hidden");
	if(hidden_gift.length > 0) 
        jQuery("#request_"+id+" .request_right_col .request-icon")[0].src = hidden_gift[0].src + '?rand='+ (new Date().getTime());//hidden_gift[0].src;

    jQuery("#request_"+id+" .request_mid_col").html( accept_text ).addClass("green-text");
    jQuery("#request_"+id).addClass( 'accepted-request' );
}
DC_Request.prototype.render=function( config ){
    var action = this.getAction();
    var sig = this.getSignature();
	var gift_icon = '';
    var icon = '';
    var from_str = '';
    
    var request_str= '<div class="blue-text">'+this.getMessage()+'</div>';

    if( action == ACTION_PARTNER_REQUEST ) {
        var from_str = '<div class="green-text">'+ i18n.get( 'DCSW_BUSS_PARTNER_TITLE', {'U':this.getFromName()})+'</div>';
        icon = '<img src="'+config['ASSETS_PATH']+'/tabs/social_wall/general/icon_partner.png" class="request-icon"/>';
    }

    else if( action == ACTION_NEIGHBOR_REQUEST ) {
        var from_str = '<div class="green-text">'+ i18n.get( 'DCSW_NEIGHBOR_TITLE', {'U':this.getFromName()})+'</div>';
        icon = '<img src="'+config['ASSETS_PATH']+'/tabs/social_wall/neighbors/icon_invite.png" class="request-icon"/>';
    }
    else if( action == ACTION_COLLECTIBLE ){
        var from_str = '<div class="green-text">'+ i18n.get( 'DCSW_COLLECTIBLES_TITLE', {'U':this.getFromName()}) +'</div>';
        icon = '<img src="'+config['ASSETS_PATH']+'/tabs/social_wall/explosions/explosion_' + this.getSku() + '.gif" class="request-icon-hidden" style="width: 0px; height: 0px;"/>';
		gift_icon = '<img src="'+config['ASSETS_PATH']+'/tabs/social_wall/general/gift_box_1.png" class="request-icon"/>';
    }
	else if( action == ACTION_CREW ){
		var from_str = '<div class="green-text">'+ i18n.get( 'DCSW_CREW_TITLE', {'U':this.getFromName()}) +'</div>';
		icon = '<img src="'+config['ASSETS_PATH']+'/tabs/social_wall/general/icon_crew.png" class="request-icon"/>';
	}
    else if( action == ACTION_GIFT ){
        if( this.accepted && this.gift_back ) {
            icon = '<img src="'+config['ASSETS_PATH']+'/tabs/social_wall/free_gifts/' + this.getSku() + '.png" class="request-icon"/>';
		}else if(this.error >= 0){
			this.showServerError(response + '0');
        } else {
            from_str = '<div class="green-text">'+ i18n.get( 'DCSW_GIFT_TITLE', {'U':this.getFromName()}) +'</div>';
            icon = '<img src="'+config['ASSETS_PATH']+'/tabs/social_wall/explosions/explosion_' + this.getSku() + '.gif" class="request-icon-hidden" style="width: 0px; height: 0px;"/>';
		    gift_icon = '<img src="'+config['ASSETS_PATH']+'/tabs/social_wall/general/gift_box_2.png" class="request-icon"/>';
        }
    }


    var url = "/dollar/AcceptFacebookRequest?request_id="+this.getId();
    var accept_url = url+"&action=accept&message_center=1&ref_uid="+this.getToId()+"&hash="+this.hash+"&sig="+sig;
    var ignore_url = url+"&action=delete&message_center=1&ref_uid="+this.getToId()+"&hash="+this.hash+"&sig="+sig;
    
    if( this.gift_back ) {
        var button = "<span id='accept_"+this.getId()+"' href='"+accept_url+"' class='uiButton uiButtonConfirm uiButtonMedium giftback-request-button'>";
        button += "<span class='dcsw_accept_text'>"+i18n.get('DCSW_SENDITBACK')+"</span></span>";
    } else {
        var button = "<span id='accept_"+this.getId()+"' href='"+accept_url+"' class='uiButton uiButtonConfirm uiButtonMedium accept-request-button'>";
        button += "<span class='dcsw_accept_text'>"+i18n.get('DCSW_ACCEPT')+"</span></span>";
        button += "<span id='ignore_"+this.getId()+"' href='"+ignore_url+"' class='dcsw_ignore_button uiButton uiButtonDefault uiButtonMedium'>"+i18n.get('DCSW_IGNORE')+"</span>";
    }
    
    var user_pic = "<img src='https://graph.facebook.com/"+this.getFromId()+"/picture' width='50' height='50'/>";

    var midcol = "<div class='request_mid_col'>"+from_str+request_str+"</div>";
    var rightcol = "<div class='request_right_col'>"+icon+gift_icon+button+"</div>";

    return user_pic + midcol + rightcol;
}
DC_Request.prototype.isNew=function(){
    return !(this.accepted || this.ignored || this.gift_back );
}





function DCPop( id, title, body, clazz ){
    var self = this;
    self.id = id;
	self.clazz = clazz;

    this.init=function(id, title, body ){
		var div = jQuery("#"+self.id);
		if(div.length != 0){
			return;
		}
        var output = "<div id='"+id+"' class='dcpop"+self.clazz+" rounded' style='z-index:1001'>";
        output+="<a class='dcpop_close'>&nbsp;</a>";
        output+="<h1 class='dcpop"+self.clazz+"_title'>"+title+"</h1>";
        output+="<p class='dcpop"+self.clazz+"_body'>"+body+"</p>";
        output+="</div>";
        jQuery( 'body' ).prepend(output);
        jQuery( '#'+id+' a.dcpop_close' ).click( self.hide );
    }
    this.show=function(){
        var pageinfo = FB.Canvas.getPageInfo();
        var width = parseInt( jQuery("#"+self.id).css("width") );
        var topValue = parseInt(pageinfo.scrollTop);
        var leftValue= parseInt(pageinfo.scrollLeft) + (760/2)-(width/2);

        jQuery("#"+self.id).css('top', topValue)
            .css('left',leftValue)
            .css('z-index',1000)
            .fadeIn();
			
		var div = jQuery("#curtain_"+self.id);
		if(div.length == 0){
			jQuery('body').prepend( "<div id='curtain_"+self.id+"' class='curtain'/>" );
		}
        jQuery("#curtain_"+self.id ).css("height", jQuery(document).height() )
            .css("width","100%").css("z-index",999);
			
    }
    this.hide=function(){
		jQuery("#"+self.id).fadeOut();
		jQuery("#curtain_"+self.id ).remove();
    }
    this.init(id,title,body);
}


var i18n = {
    '_i18n':[],

    'config':function( config ){
        this._i18n = config;
    },

    'get':function( tid, params ) {
        var text = this._i18n[tid];
        if( text == undefined ) text="*"+tid;
        return i18n.parse( text, params );
    },

    'parse':function( text, params ){
        if(params == null) params = {};
        for(key in params) {
            var token = "%"+key;
            while( text.indexOf(token) !== -1){
                text = text.replace( token, params[key] );
            }

        }
        return text;
    }
}

function DC_Neighbors( id, uid, hash, access_token, config ){
    this.id = id;
    this.uid = uid;
    this.hash=hash;
    this.access_token = access_token;
    this.config = config;
    var userToSendGift = -1;

    this.element = document.getElementById(id);
    this.data = {};
    this.friends = [];
    this._cacheFriendsById = [];
    this._limit = 25;

    var initial_str = "<span class='nb_close'>&nbsp;</span><div id='nb_header'></div>";
    initial_str += "<div class='nb_outer'><div id='nb_tabs'></div></div>";
    initial_str += "<div class='nb_outer'><div id='nb_body'></div></div>";
    initial_str += "<div id='nb_footer'></div>";
    this.element.innerHTML = initial_str;
    jQuery('.nb_close').click( this.closeEvent );
    this.refresh();

}
DC_Neighbors.prototype.closeEvent=function(){
    clickOnTab("labelFor_gameEmbed");
}
DC_Neighbors.prototype.reload=function(){
    if (jQuery("#neighbors").css("visibility") == "visible" ) 
        return false;

    this.refresh();
}
DC_Neighbors.prototype.refresh=function(){
    var self=this; // store this context in self.
    var url = "/dollar/info?hash="+this.hash+"&ref_uid="+this.uid+"&oauth_token="+this.access_token+"&action=";

    //jQuery.get( url+"getNeighborIds_availablesToSendNeighborRequest" ,
    jQuery.ajaxSetup({cache: false});
    jQuery.get( url+"getNeighborAllInfo" ,
        function(response){
            response = response['neighbors'];
            self.data['non_neighbors'] = response[0]['non_neighbors'];
            self.data['pending'] = response[1]['pending'];
            self.data['neighbors'] = response[2]['neighbors'];

            FB.api( "/me/friends", function(r){
                if( "error" in r ) {
                    //alert(r.error.message);
                } else {
                    self.friends = r;
                    self.render();
                }
            });
    }, "json");
}
DC_Neighbors.prototype.getFriendName=function(id){
    if( this._cacheFriendsById[id] != undefined ) 
        return this._cacheFriendsById[id];

    for( var f=0; f< this.friends.data.length; f++){
        var friend = this.friends.data[f];
        if( friend.id == id ) {
            this._cacheFriendsById[id] = friend.name;
            return friend.name;
        }
    }
    return false;
}
DC_Neighbors.prototype._sortByName=function(a,b,self){
    var friendA = self.getFriendName(a);
    var friendB = self.getFriendName(b);
    if( friendA == friendB ) return 0;
    if( friendA < friendB ) return -1;
    return 1;
}
DC_Neighbors.prototype.render=function(){
    var content = "";
    var self=this;
    this._sortByName = function(a,b){
    
    }
/* work in progress
    this.data['non_neighbors'].sort( function(a,b){return self._sortByName(a,b,self)} );
    this.data['pending'].sort( function(a,b){return self._sortByName(a,b,self)} );
    this.data['neighbors'].sort( function(a,b){return self._sortByName(a,b,self)} );
*/

    var worker = {
        i: 0,
        type: 'non_neighbors',
        limit: this._limit,
        display: true,
        work: function( context, content ){
            //console.log("working "+this.type+"["+this.i+"]");
            var work_units = 0;
            var finished = false;

            while( work_units < 5 ){
                if( this.i == context.data[this.type].length) {
                    finished=true;
                    break;
                }

                if( this.i == this.limit ){
                    content += "<div class='show_more_friends rounded'>Show more...</div>";
                    this.display = false;
                }

                var neighbor = context.data[this.type][this.i];

                if( this.type == 'non_neighbors' )
                    content += context.render_non_neighbor( neighbor, this.display );
                if( this.type == 'pending' )
                    content += context.render_pending( neighbor, this.display );
                if( this.type == 'neighbors' )
                    content += context.render_neighbor( neighbor, this.display );

                work_units++;
                this.i++;
            }

            if( finished ) {
                this.onFinish( context, content );
            } else {
                setTimeout( function(){ worker.work(context,content) }, 1 );
            }
        },
        onFinish: function(context,content){
            this.i = 0;
            this.display = true;

            if( this.type == 'non_neighbors') {
                this.type='pending';
                worker.work( context, content );
                return;
            } else
            if( this.type == 'pending') {
                this.type='neighbors';
                worker.work( context, content );
                return;
            }

            jQuery("#nb_body").html( content );
            context.render_footer();

            jQuery(".send-gift-button").click( self, self.sendGiftEvent );
            jQuery(".add-neighbor-button").click( self, self.addNeighborEvent );
            jQuery(".remove-neighbor-button").click( self, self.removeNeighborEvent );
            jQuery(".show_more_friends").click( self, self.showMoreFriendsEvent );
    
        }
    };
    worker.work( self, content );

}

DC_Neighbors.prototype.bindEvents = function(id)
{
	jQuery(".send-gift-button").unbind('click');
	jQuery(".add-neighbor-button").unbind('click');
	jQuery(".remove-neighbor-button").unbind('click');
	
	jQuery(".send-gift-button").click( this, this.sendGiftEvent );
	jQuery(".add-neighbor-button").click( this, this.addNeighborEvent );
	jQuery(".remove-neighbor-button").click( this, this.removeNeighborEvent );
}

DC_Neighbors.prototype.render_footer=function(){
    var locale = this.config['LOCALE'].split("_")[0];
    if( locale != "en" ) {
        var supported = {'en':'','es':'','fr':'','it':'','de':'','pt':'','zh':'','tr':'','id':'','ru':'','th':'','ja':'','el':'','pl':'','da':'','ms':'','hr':'','sr':'','ro':''};
        if( locale in supported ) {
            var img = this.config['ASSETS_PATH']+"/tabs/social_wall/neighbors/footer_"+locale+".png";
            jQuery("#nb_footer").css("background-image", "url("+img+")");
        }
    }
    var footer = "<span id='dcnb_invite_button' class='uiButton uiButtonConfirm uiButtonMedium medium-size' onclick='launchFacebookInvite();'>"+i18n.get("INVITE_FRIENDS")+"</span>";
    jQuery("#nb_footer").css("cursor","pointer");
    jQuery("#nb_footer").unbind('click', launchFacebookInvite );
    jQuery("#nb_footer").bind('click', launchFacebookInvite );
}
DC_Neighbors.prototype.render_non_neighbor = function( id, display ){
    var name = "<div class='green-text'>"+this.getFriendName( id )+"</div>";
    var atr = ( display )?"src":"fakesrc";
    var user_pic = "<img "+atr+"='https://graph.facebook.com/"+id+"/picture' width='50' height='50' align='top'/>";
    var midcol = "<div class='request_mid_col'>";
    midcol+= "<span>"+name+i18n.get("MNT_ADDME")+"</span></div>";


    var sendGift_button = "<span id='sendgift_"+id+"' class='uiButton uiButtonConfirm uiButtonMedium send-gift-button medium-size'>";
    sendGift_button += i18n.get('FGT_SEND_BUTTON') + "</span>";

    var addAsNeighbor_button = "<span id='addAsNeighbor_"+id+"' class='uiButton uiButtonConfirm uiButtonMedium add-neighbor-button medium-size'>";
    addAsNeighbor_button += i18n.get('MNT_SEND_BUTTON') + "</span>";

    var rightcol = "<div class='request_right_col' style='text-align:right'>";
    rightcol += "<img src='"+this.config['ASSETS_PATH']+"/tabs/social_wall/general/icon_invite.png' style='float:left; height:50px' align='top'/>";
    rightcol += "<div style='float:right; min-width: 150px'>"+sendGift_button +"<br/>"+ addAsNeighbor_button+"</div>";
    rightcol += "</div>";

    var style = (display === false) ? " style='display:none'": "";
    var container = "<div id='neighbor_"+id+"' class='neighbor'"+style+">"+user_pic+midcol+rightcol+"</div>";
    return container;
}
DC_Neighbors.prototype.render_neighbor = function( id, display ){
    var style = (display === false) ? " style='display:none'": "";
    var name = "<div class='green-text'>"+this.getFriendName( id )+"</div>";

    var atr = ( display )?"src":"fakesrc";
    var user_pic = "<img "+atr+"='https://graph.facebook.com/"+id+"/picture' width='50' height='50' align='top'/>";

    var midcol = "<div class='request_mid_col'>"+name+"</div>";

    var sendGift_button = "<span id='sendgift_"+id+"' class='uiButton uiButtonConfirm uiButtonMedium send-gift-button medium-size'>";
    sendGift_button += i18n.get('FGT_SEND_BUTTON') + "</span>";

    var remove_button = "<span id='removeNeighbor_"+id+"' class='uiButton uiButtonDefault uiButtonMedium remove-neighbor-button medium-size'>";
    remove_button += i18n.get('MNT_REMOVE') + "</span>";

    var icon = "<img src='"+this.config['ASSETS_PATH']+"/tabs/social_wall/neighbors/icon_invite.png' style='float:left; height:50px' align='top'/>";
    var rightcol = "<div class='request_right_col' style='text-align: right'>"+icon;
    rightcol += "<div style='float:right; min-width: 150px'>"+sendGift_button +"<br/>"+ remove_button + "</div>";
    rightcol += "</div>";

    var container = "<div id='neighbor_"+id+"' class='neighbor'"+style+">"+user_pic+midcol+rightcol+"</div>";
    return container;
}
DC_Neighbors.prototype.render_pending = function( id, display ){
    var name = "<span class='green-text'>"+this.getFriendName( id )+"</span><br/>";

    var atr = ( display )?"src":"fakesrc";
    var user_pic = "<img "+atr+"='https://graph.facebook.com/"+id+"/picture' width='50' height='50' align='top'/>";

    var sendGift_button = "<span id='sendgift_"+id+"' class='uiButton uiButtonConfirm uiButtonMedium send-gift-button medium-size'>";
    sendGift_button += i18n.get('FGT_SEND_BUTTON') + "</span>";

    var retry_button = "<span id='retryNeighbor_"+id+"' class='uiButton uiButtonDefault uiButtonMedium add-neighbor-button medium-size'>";
    retry_button += i18n.get('MNT_SEND_REMINDER_BUTTON') + "</span>";

    var midcol = "<div class='request_mid_col'>"+name+i18n.get('MNT_PENDING')+"</div>";

    var icon = "<img src='"+this.config['ASSETS_PATH']+"/tabs/social_wall/neighbors/icon_invite_pending.png' style='float:left; height:50px' align='top'/>";
    var rightcol = "<div class='request_right_col' style='text-align: right'>"+icon;
    rightcol += "<div style='float:right; min-width: 150px;'>"+sendGift_button +"<br/>"+ retry_button + "</div>";
    rightcol += "</div>";
    //var rightcol = "<div class='request_right_col'>"+sendGift_button + "<br/>" + remove_button + "</div>";
    
    var style = (display === false) ? " style='display:none'": "";
    var container = "<div id='neighbor_"+id+"' class='neighbor neighbor-request-pending rounded'"+style+">"+user_pic+midcol+rightcol+"</div>";

    return container;
}
DC_Neighbors.prototype.showMoreFriendsEvent = function( data ){
    var self = data.data;
    var limit = self._limit;
    var context = this;

    var elements = jQuery(this).nextAll().length;
    if( elements < limit ) limit = elements;

    jQuery(this).nextAll().each( function(index){
        if(index > limit ) {
            jQuery(this).after( jQuery(context).detach() );
            return false;
        }
        jQuery(this).fadeIn().children("img").each( function(){ 
            jQuery(this).attr("src",jQuery(this).attr("fakesrc") ); 
        });
    } );
}
DC_Neighbors.prototype.sendGiftEvent = function( data ){
    // this is a jQuery event handler
    // here, "this" is the jQuery object of the source element
    var self = data.data;
	self.userToSendGift = jQuery(this)[0].id.split("_")[1];
	clickOnTab('labelFor_gifts');
}
DC_Neighbors.prototype.setAsPending = function(data){
    var id = parseInt( data.fExtId );
    
    for( var i in this.data['non_neighbors'] ) {
        if( this.data['non_neighbors'][i] ==  id ) {
            this.data['non_neighbors'].splice( i, 1);
        }
    }
    this.data['pending'].push( id );

    jQuery( "#neighbor_"+id ).replaceWith( this.render_pending(id,true) );
	this.bindEvents(id);
}
DC_Neighbors.prototype.removeNeighbor=function(id){
    var id = parseInt( id );
    
    for( var i in this.data['neighbors'] ) {
        if( this.data['neighbors'][i] ==  id ) {
            this.data['neighbors'].splice( i, 1);
        }
    }
    this.data['non_neighbors'].push( id );

    jQuery( "#neighbor_"+id ).replaceWith( this.render_non_neighbor(id,true) );
	this.bindEvents(id);
}
DC_Neighbors.prototype.addNeighborEvent = function(ev){
    // this is a jQuery event handler
    // here, "this" is the jQuery object of the source element
    var self = ev.data;
	var targetUser = jQuery(this)[0].id.split("_")[1];
	launchFacebookRequest( {'fExtId':targetUser,
							'action':'neighborRequest'}, null, {"object":self, "method":self.setAsPending} );
}
DC_Neighbors.prototype.removeNeighborEvent = function(ev){
    // this is a jQuery event handler
    // here, "this" is the jQuery object of the source element
    var self = ev.data;
	var targetUser = jQuery(this)[0].id.split("_")[1];
	jQuery.get('/dollar/friend_select?action=neighborRemove&new_req=1&ids[]='+targetUser+'&hash='+DCSW.hash+'&ref_uid='+self.uid);
	sendTask_to_flash("messageRemoveNeighbor:"+targetUser);
    self.removeNeighbor( targetUser );
}
DC_Neighbors.prototype.cancelNeighborRequestEvent = function(ev){
    // this is a jQuery event handler
    // here, "this" is the jQuery object of the source element
    var self = ev.data;
	var targetUser = jQuery(this)[0].id.split("_")[1];
	jQuery.get('/dollar/friend_select?action=neighborRequestDelete&new_req=1&ids[]='+targetUser+'&hash='+DCSW.hash+'&ref_uid='+self.uid);
}
