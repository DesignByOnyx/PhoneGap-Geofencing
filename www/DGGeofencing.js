/**
 * Geofencing.js
 *
 * Phonegap Geofencing Plugin
 * Copyright (c) Dov Goldberg 2012
 * http://www.ogonium.com
 * dov.goldberg@ogonium.com
 *
 */

var exec = require('cordova/exec'),
	pendingRegionUpdates = [],
	pendingLocationUpdates = [],
	regionCallbacks = [],
	locationCallbacks = [];


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
	
	onRegionUpdate: function(callback) {
		if( typeof callback === 'function' ) {
			// TODO: check if callback function already exists
			regionCallbacks.push(callback);
		}
		
		if(pendingRegionUpdates.length) {
			for(var i = 0; i < pendingRegionUpdates.length; i++) {
				this.regionMonitorUpdate( pendingRegionUpdates[i] );
			}
		}
	},
	
	onLocationUpdate: function(callback) {
		if( typeof callback === 'function' ) {
			// TODO: check if callback function already exists
			locationCallbacks.push(callback);
		}
		
		if(pendingLocationUpdates.length) {
			for(var i = 0; i < pendingLocationUpdates.length; i++) {
				this.regionMonitorUpdate( pendingLocationUpdates[i] );
			}
		}
	},
	
	/* 
	This is used so the JavaScript can be updated when a region is entered or exited
	*/
	regionMonitorUpdate: function(regionUpdate) {
		if( regionCallbacks.length ) {
			//steal.dev.log("regionMonitorUpdate: " + JSON.stringify(regionupdate));
			/*
			var ev = document.createEvent('HTMLEvents');
			ev.regionUpdate = regionUpdate;
			ev.initEvent('region-update', true, true, arguments);
			document.dispatchEvent(ev);
			*/
			for(var i = 0; i < regionCallbacks.length; i++) {
				if( typeof regionCallbacks[i] === "function" ) {
					regionCallbacks[i]( regionUpdate );
				}
			}
		} else {
			pendingRegionUpdates.push(regionUpdate);
		}
	},
	
	/* 
	This is used so the JavaScript can be updated when a significant change has occured
	*/
	locationMonitorUpdate: function(locationUpdate) {
		if( locationCallbacks.length ) {
			//steal.dev.log("locationMonitorUpdate: " + JSON.stringify(locationupdate));
			/*
			var ev = document.createEvent('HTMLEvents');
			ev.locationUpdate = [locationUpdate];
			ev.initEvent('location-update', true, true, arguments);
			document.dispatchEvent(ev);
			*/
			for(var i = 0; i < locationCallbacks.length; i++) {
				if( typeof locationCallbacks[i] === "function" ) {
					locationCallbacks[i]( locationUpdate );
				}
			}
		} else {
			pendingLocationUpdates.push(locationUpdate);
		}
	}
};

if (typeof module != 'undefined' && module.exports) {
    module.exports = DGGeofencing;
}
