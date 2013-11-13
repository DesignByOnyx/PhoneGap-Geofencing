/**
 * Geofencing.js
 *
 * Phonegap Geofencing Plugin
 * Copyright (c) Dov Goldberg 2012
 * http://www.ogonium.com
 * dov.goldberg@ogonium.com
 *
 */
 
var exec = require('cordova/exec');


var DGGeofencing = {
/*
     Params:
     NONE
     */
	initCallbackForRegionMonitoring: function(params, success, fail) {
		return exec(success, fail, "DGGeofencing", "initCallbackForRegionMonitoring", params);
	},

/*
     Params:
     #define KEY_REGION_ID       @"fid"
     #define KEY_REGION_LAT      @"latitude"
     #define KEY_REGION_LNG      @"longitude"
     #define KEY_REGION_RADIUS   @"radius"
     #define KEY_REGION_ACCURACY @"accuracy"
     */
	startMonitoringRegion: function(params, success, fail) {
		return exec(success, fail, "DGGeofencing", "startMonitoringRegion", params);
	},

/*
	Params:
	#define KEY_REGION_ID      @"fid"
	#define KEY_REGION_LAT     @"latitude"
    #define KEY_REGION_LNG     @"longitude"
	*/
	stopMonitoringRegion: function(params, success, fail) {
		return exec(success, fail, "DGGeofencing", "stopMonitoringRegion", params);
	},

/*
	Params:
	NONE
	*/
	getWatchedRegionIds: function(success, fail) {
		return exec(success, fail, "DGGeofencing", "getWatchedRegionIds", []);
	},

/*
	Params:
	NONE
	*/
	getPendingRegionUpdates: function(success, fail) {
		return exec(success, fail, "DGGeofencing", "getPendingRegionUpdates", []);
	},

/*
	Params:
	NONE
	*/
	startMonitoringSignificantLocationChanges: function(success, fail) {
		return exec(success, fail, "DGGeofencing", "startMonitoringSignificantLocationChanges", []);
	},

/*
	Params:
	NONE
	*/
	stopMonitoringSignificantLocationChanges: function(success, fail) {
		return exec(success, fail, "DGGeofencing", "stopMonitoringSignificantLocationChanges", []);
	},
	
	/* 
	This is used so the JavaScript can be updated when a region is entered or exited
	*/
	regionMonitorUpdate: function(regionupdate) {
		steal.dev.log("regionMonitorUpdate: " + JSON.stringify(regionupdate));
		var ev = document.createEvent('HTMLEvents');
		ev.regionupdate = regionupdate;
		ev.initEvent('region-update', true, true, arguments);
		document.dispatchEvent(ev);
	},
	
	/* 
	This is used so the JavaScript can be updated when a significant change has occured
	*/
	locationMonitorUpdate: function(locationupdate) {
		steal.dev.log("locationMonitorUpdate: " + JSON.stringify(locationupdate));
		var ev = document.createEvent('HTMLEvents');
		ev.locationupdate = locationupdate;
		ev.initEvent('location-update', true, true, arguments);
		document.dispatchEvent(ev);
	}
};

if (typeof module != 'undefined' && module.exports) {
    module.exports = DGGeofencing;
}
