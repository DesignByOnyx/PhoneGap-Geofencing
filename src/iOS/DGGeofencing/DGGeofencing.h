
#import <CoreLocation/CoreLocation.h>
#import <Cordova/CDVPlugin.h>

enum DGLocationStatus {
    PERMISSIONDENIED = 1,
    POSITIONUNAVAILABLE,
    TIMEOUT
};
typedef NSUInteger DGLocationStatus;

enum DGGeofencingStatus {
    GEOFENCINGPERMISSIONDENIED = 4,
    GEOFENCINGUNAVAILABLE=5,
    GEOFENCINGTIMEOUT=6
};
typedef NSUInteger DGGeofencingStatus;


// simple object to keep track of location information
@interface DGLocationData : NSObject {
    DGLocationStatus locationStatus;
    DGGeofencingStatus geofencingStatus;
    CLLocation* locationInfo;
    NSMutableArray* locationCallbacks;
    NSMutableDictionary* geofencingCallbacks;
    NSMutableDictionary* lsNewGeofences;
}

@property (nonatomic, assign) DGLocationStatus locationStatus;
@property (nonatomic, assign) DGGeofencingStatus geofencingStatus;
@property (nonatomic, strong) CLLocation* locationInfo;
@property (nonatomic, strong) NSMutableArray* locationCallbacks;
@property (nonatomic, strong) NSMutableDictionary* geofencingCallbacks;
@property (nonatomic, strong) NSMutableDictionary* lsNewGeofences;

@end

//=====================================================
// DGGeofencing
//=====================================================

@interface DGGeofencing : CDVPlugin <CLLocationManagerDelegate> {
    @private BOOL __hasGeofence;
    @private BOOL __isUpdatingLocation;
    @private BOOL __isMonitoringSignificantLocation;
    DGLocationData* locationData;
}

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) DGLocationData* locationData;
@property (nonatomic, assign) BOOL didLaunchForRegionUpdate;

+(DGGeofencing*)sharedGeofencingHelper;

- (BOOL) isLocationServicesEnabled;
- (BOOL) isAuthorized;
- (BOOL) isRegionMonitoringAvailable;
- (BOOL) isRegionMonitoringEnabled;
- (BOOL) isSignificantLocationChangeMonitoringAvailable;

#pragma mark Plugin Functions
- (void) initCallbackForRegionMonitoring:(CDVInvokedUrlCommand*)command forRegion:(CLRegion*)region;
- (void) startMonitoringRegion:(CDVInvokedUrlCommand*)command;
- (void) stopMonitoringRegion:(CDVInvokedUrlCommand*)command;
- (NSArray *) getMonitoredRegions;
- (void) startMonitoringSignificantLocationChanges:(CDVInvokedUrlCommand*)command;
- (void) stopMonitoringSignificantLocationChanges:(CDVInvokedUrlCommand*)command;

@end