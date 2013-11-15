
#import "DGGeofencing.h"

@implementation DGLocationData

@synthesize locationStatus, geofencingStatus, locationInfo, locationCallbacks, geofencingCallbacks;
- (DGLocationData*)init
{
    self = (DGLocationData*)[super init];
    if (self) {
        self.locationInfo = nil;
        self.locationCallbacks = nil;
        self.geofencingCallbacks = nil;
    }
    return self;
}

@end

@implementation DGGeofencing

@synthesize locationData, locationManager;

- (CDVPlugin*)initWithWebView:(UIWebView*)theWebView
{
    self = (DGGeofencing*)[super initWithWebView:(UIWebView*)theWebView];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self; // Tells the location manager to send updates to this object
        __locationStarted = NO;
        __highAccuracyEnabled = NO;
        self.locationData = nil;
    }
    return self;
}

#pragma mark Location and Geofencing Permissions
- (BOOL) isSignificantLocationChangeMonitoringAvailable
{
	BOOL significantLocationChangeMonitoringAvailablelassPropertyAvailable = [CLLocationManager respondsToSelector:@selector(significantLocationChangeMonitoringAvailable)];
    if (significantLocationChangeMonitoringAvailablelassPropertyAvailable)
    {
        BOOL significantLocationChangeMonitoringAvailable = [CLLocationManager significantLocationChangeMonitoringAvailable];
        return  (significantLocationChangeMonitoringAvailable);
    }
    
    // by default, assume NO
    return NO;
}

- (BOOL) isRegionMonitoringAvailable
{
	BOOL regionMonitoringAvailableClassPropertyAvailable = [CLLocationManager respondsToSelector:@selector(regionMonitoringAvailable)];
    if (regionMonitoringAvailableClassPropertyAvailable)
    {
        BOOL regionMonitoringAvailable = [CLLocationManager regionMonitoringAvailable];
        return  (regionMonitoringAvailable);
    }
    
    // by default, assume NO
    return NO;
}

- (BOOL) isRegionMonitoringEnabled
{
	BOOL regionMonitoringEnabledClassPropertyAvailable = [CLLocationManager respondsToSelector:@selector(regionMonitoringEnabled)];
    if (regionMonitoringEnabledClassPropertyAvailable)
    {
        BOOL regionMonitoringEnabled = [CLLocationManager regionMonitoringEnabled];
        return  (regionMonitoringEnabled);
    }
    
    // by default, assume NO
    return NO;
}

- (BOOL) isAuthorized
{
	BOOL authorizationStatusClassPropertyAvailable = [CLLocationManager respondsToSelector:@selector(authorizationStatus)]; // iOS 4.2+
    if (authorizationStatusClassPropertyAvailable)
    {
        NSUInteger authStatus = [CLLocationManager authorizationStatus];
        return  (authStatus == kCLAuthorizationStatusAuthorized) || (authStatus == kCLAuthorizationStatusNotDetermined);
    }
    
    // by default, assume YES (for iOS < 4.2)
    return YES;
}

- (BOOL) isLocationServicesEnabled
{
	BOOL locationServicesEnabledInstancePropertyAvailable = [[self locationManager] respondsToSelector:@selector(locationServicesEnabled)]; // iOS 3.x
	BOOL locationServicesEnabledClassPropertyAvailable = [CLLocationManager respondsToSelector:@selector(locationServicesEnabled)]; // iOS 4.x
    
	if (locationServicesEnabledClassPropertyAvailable)
	{ // iOS 4.x
		return [CLLocationManager locationServicesEnabled];
	}
	else if (locationServicesEnabledInstancePropertyAvailable)
	{ // iOS 2.x, iOS 3.x
		return [(id)[self locationManager] locationServicesEnabled];
	}
	else
	{
		return NO;
	}
}


#pragma mark Plugin Functions


- (void) initCallbackForRegionMonitoring:(CDVInvokedUrlCommand *)command forRegion:(CLRegion *)region {
    if (!self.locationData) {
        self.locationData = [[DGLocationData alloc] init];
    }
    DGLocationData* lData = self.locationData;
    
    if (!lData.geofencingCallbacks) {
        lData.geofencingCallbacks = [[NSMutableDictionary alloc] init];
    }
    
    // Save a reference for the regionId/commandId
    //NSDictionary *dict = @{@"fid": region.identifier, @"commandId": command.callbackId};
    //[lData.geofencingCallbacks addObject:dict];
    [lData.geofencingCallbacks setObject:command.callbackId forKey:region.identifier];
}
- (void) clearCallbackForRegionMonitoring:(NSString *)regionId {
    // Remove callback for region
    DGLocationData* lData = self.locationData;
    if([lData.geofencingCallbacks count] > 0 && [lData.geofencingCallbacks objectForKey:regionId]) {
        [lData.geofencingCallbacks removeObjectForKey:regionId];
    }
}
- (void) startMonitoringRegion:(CDVInvokedUrlCommand*)command {
    NSString* regionId = [command.arguments objectAtIndex:0];
    NSString *latitude = [command.arguments objectAtIndex:1];
    NSString *longitude = [command.arguments objectAtIndex:2];
    double radius = [[command.arguments objectAtIndex:3] doubleValue];
    //CLLocationAccuracy accuracy = [[command.arguments objectAtIndex:4] floatValue];
    
    DGLocationData* lData = self.locationData;
    NSString *callbackId = command.callbackId;
    
    if ([self isLocationServicesEnabled] == NO) {
        lData.locationStatus = PERMISSIONDENIED;
        NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
        [posError setObject:[NSNumber numberWithInt:PERMISSIONDENIED] forKey:@"code"];
        [posError setObject:@"Location services are disabled." forKey:@"message"];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:posError];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    } if ([self isAuthorized] == NO) {
        lData.locationStatus = PERMISSIONDENIED;
        NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
        [posError setObject:[NSNumber numberWithInt:PERMISSIONDENIED] forKey:@"code"];
        [posError setObject:@"Location services are not authorized." forKey:@"message"];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:posError];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    } if ([self isRegionMonitoringAvailable] == NO) {
        lData.geofencingStatus = GEOFENCINGUNAVAILABLE;
        NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
        [posError setObject:[NSNumber numberWithInt:GEOFENCINGUNAVAILABLE] forKey:@"code"];
        [posError setObject:@"Geofencing services are disabled." forKey:@"message"];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:posError];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    } if ([self isRegionMonitoringEnabled] == NO) {
        lData.geofencingStatus = GEOFENCINGPERMISSIONDENIED;
        NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
        [posError setObject:[NSNumber numberWithInt:GEOFENCINGPERMISSIONDENIED] forKey:@"code"];
        [posError setObject:@"Geofencing services are not authorized." forKey:@"message"];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:posError];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    } else {
        // Start region monitoring
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
        CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:coord radius:radius identifier:regionId];
        
        // Go ahead and register the callback commandId
        [self initCallbackForRegionMonitoring:command forRegion:region];
        
        [self.locationManager startMonitoringForRegion:region];
        
        /*
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
	    [result setKeepCallbackAsBool:YES];
	    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
         */
    }
}

- (void) stopMonitoringRegion:(CDVInvokedUrlCommand*)command {
    NSString *callbackId = command.callbackId;
    
    // Parse Incoming Params
    NSString *regionId = [command.arguments objectAtIndex:0];
    NSString *latitude = [command.arguments objectAtIndex:1];
    NSString *longitude = [command.arguments objectAtIndex:2];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:coord radius:10.0 identifier:regionId];
    [[self locationManager] stopMonitoringForRegion:region];
    
    // return success to callback
    NSMutableDictionary* returnInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    NSNumber* timestamp = [NSNumber numberWithDouble:([[NSDate date] timeIntervalSince1970] * 1000)];
    [returnInfo setObject:timestamp forKey:@"timestamp"];
    [returnInfo setObject:@"Region was removed successfully" forKey:@"message"];
    [returnInfo setObject:regionId forKey:@"regionId"];
    [returnInfo setObject:@"monitorremoved" forKey:@"callbacktype"];
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnInfo];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}


- (void) startMonitoringSignificantLocationChanges:(CDVInvokedUrlCommand*)command {
    DGLocationData* lData = self.locationData;
    NSString *callbackId = command.callbackId;
    if (![self isLocationServicesEnabled])
	{
		BOOL forcePrompt = NO;
		if (!forcePrompt)
		{
            lData.locationStatus = GEOFENCINGPERMISSIONDENIED;
            NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
            [posError setObject:[NSNumber numberWithInt:GEOFENCINGPERMISSIONDENIED] forKey:@"code"];
            [posError setObject:@"Location services are not enabled." forKey:@"message"];
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:posError];
            [result setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
			return;
		}
    }
    
    if (![self isAuthorized])
    {
        NSString* message = nil;
        BOOL authStatusAvailable = [CLLocationManager respondsToSelector:@selector(authorizationStatus)]; // iOS 4.2+
        if (authStatusAvailable) {
            NSUInteger code = [CLLocationManager authorizationStatus];
            if (code == kCLAuthorizationStatusNotDetermined) {
                // could return POSITION_UNAVAILABLE but need to coordinate with other platforms
                message = @"User undecided on application's use of location services";
            } else if (code == kCLAuthorizationStatusRestricted) {
                message = @"application use of location services is restricted";
            }
        }
        //PERMISSIONDENIED is only PositionError that makes sense when authorization denied
        lData.locationStatus = GEOFENCINGPERMISSIONDENIED;
        NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
        [posError setObject:[NSNumber numberWithInt:GEOFENCINGPERMISSIONDENIED] forKey:@"code"];
        [posError setObject:message forKey:@"message"];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:posError];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        
        return;
    }
    
    if (![self isSignificantLocationChangeMonitoringAvailable])
	{
        lData.locationStatus = GEOFENCINGUNAVAILABLE;
        NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
        [posError setObject:[NSNumber numberWithInt:GEOFENCINGPERMISSIONDENIED] forKey:@"code"];
        [posError setObject:@"Location services are not available." forKey:@"message"];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:posError];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        return;
    }
    
    [[self locationManager] startMonitoringSignificantLocationChanges];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

- (void) stopMonitoringSignificantLocationChanges:(CDVInvokedUrlCommand*)command {
    DGLocationData* lData = self.locationData;
    NSString *callbackId = command.callbackId;
    if (![self isLocationServicesEnabled])
	{
		BOOL forcePrompt = NO;
		if (!forcePrompt)
		{
            lData.locationStatus = GEOFENCINGPERMISSIONDENIED;
            NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
            [posError setObject:[NSNumber numberWithInt:GEOFENCINGPERMISSIONDENIED] forKey:@"code"];
            [posError setObject:@"Location services are not enabled." forKey:@"message"];
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:posError];
            [result setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
			return;
		}
    }
    
    if (![self isAuthorized])
    {
        NSString* message = nil;
        BOOL authStatusAvailable = [CLLocationManager respondsToSelector:@selector(authorizationStatus)]; // iOS 4.2+
        if (authStatusAvailable) {
            NSUInteger code = [CLLocationManager authorizationStatus];
            if (code == kCLAuthorizationStatusNotDetermined) {
                // could return POSITION_UNAVAILABLE but need to coordinate with other platforms
                message = @"User undecided on application's use of location services";
            } else if (code == kCLAuthorizationStatusRestricted) {
                message = @"application use of location services is restricted";
            }
        }
        //PERMISSIONDENIED is only PositionError that makes sense when authorization denied
        lData.locationStatus = GEOFENCINGPERMISSIONDENIED;
        NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
        [posError setObject:[NSNumber numberWithInt:GEOFENCINGPERMISSIONDENIED] forKey:@"code"];
        [posError setObject:message forKey:@"message"];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:posError];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        
        return;
    }
    
    if (![self isSignificantLocationChangeMonitoringAvailable])
	{
        lData.locationStatus = GEOFENCINGUNAVAILABLE;
        NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
        [posError setObject:[NSNumber numberWithInt:GEOFENCINGPERMISSIONDENIED] forKey:@"code"];
        [posError setObject:@"Location services are not available." forKey:@"message"];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:posError];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        return;
    }
    
    [[self locationManager] stopMonitoringSignificantLocationChanges];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

#pragma mark Location Delegate Callbacks

/*
 *  locationManager:didStartMonitoringForRegion:
 *
 *  Discussion:
 *    Invoked when a monitoring for a region started successfully.
 */
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSString *regionId = region.identifier;
    DGLocationData* lData = self.locationData;
    
    // Get the commandId for this region so we can resolve it
    NSString* callbackId = [lData.geofencingCallbacks objectForKey:regionId];
    
    // return success to callback
    NSMutableDictionary* returnInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    NSNumber* timestamp = [NSNumber numberWithDouble:([[NSDate date] timeIntervalSince1970] * 1000)];
    [returnInfo setObject:timestamp forKey:@"timestamp"];
    [returnInfo setObject:@"Region was successfully added for monitoring" forKey:@"message"];
    [returnInfo setObject:regionId forKey:@"regionId"];
    [returnInfo setObject:@"monitorstart" forKey:@"callbacktype"];
    
    // Go ahead and fire the didEnterRegion event
    // TODO: get current location and make sure we are in the region
    [self locationManager:manager didEnterRegion:region];
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnInfo];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    
    // Clear the callback... we no longer need it
    [self clearCallbackForRegionMonitoring:regionId];
}


/*
 *  locationManager:monitoringDidFailForRegion:withError:
 *
 *  Discussion:
 *    Invoked when a region monitoring error has occurred. Error types are defined in "CLError.h".
 */
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSString *regionId = region.identifier;
    DGLocationData* lData = self.locationData;
    NSString* callbackId = [lData.geofencingCallbacks objectForKey:regionId];
    // return error to callback
    
    NSMutableDictionary* returnInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    NSNumber* timestamp = [NSNumber numberWithDouble:([[NSDate date] timeIntervalSince1970] * 1000)];
    [returnInfo setObject:timestamp forKey:@"timestamp"];
    [returnInfo setObject:error.description forKey:@"message"];
    [returnInfo setObject:regionId forKey:@"regionId"];
    [returnInfo setObject:@"monitorfail" forKey:@"callbacktype"];
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnInfo];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    
    // Clear the callback... we no longer need it
    [self clearCallbackForRegionMonitoring:regionId];
}

/*
 *  locationManager:didEnterRegion:
 *
 *  Discussion:
 *    Invoked when the user enters a monitored region.  This callback will be invoked for every allocated
 *    CLLocationManager instance with a non-nil delegate that implements this method.
 */
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSDictionary *dict = @{
        @"status": @"enter",
        @"fid": region.identifier
    };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options: 0 error: nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *jsStatement = [NSString stringWithFormat:@"DGGeofencing.regionMonitorUpdate(%@);", jsonString];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStatement];
}

/*
 *  locationManager:didExitRegion:
 *
 *  Discussion:
 *    Invoked when the user exits a monitored region.  This callback will be invoked for every allocated
 *    CLLocationManager instance with a non-nil delegate that implements this method.
 */
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSDictionary *dict = @{
                           @"status": @"left",
                           @"fid": region.identifier
                           };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options: 0 error: nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *jsStatement = [NSString stringWithFormat:@"DGGeofencing.regionMonitorUpdate(%@);", jsonString];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStatement];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSDictionary *dict = @{
                           @"new_timestamp": [NSNumber numberWithDouble:[newLocation.timestamp timeIntervalSince1970]],
                           @"new_speed": [NSNumber numberWithDouble:newLocation.speed],
                           @"new_course": [NSNumber numberWithDouble:newLocation.course],
                           @"new_verticalAccuracy": [NSNumber numberWithDouble:newLocation.verticalAccuracy],
                           @"new_horizontalAccuracy": [NSNumber numberWithDouble:newLocation.horizontalAccuracy],
                           @"new_altitude": [NSNumber numberWithDouble:newLocation.altitude],
                           @"new_latitude": [NSNumber numberWithDouble:newLocation.coordinate.latitude],
                           @"new_longitude": [NSNumber numberWithDouble:newLocation.coordinate.longitude],
                           
                           @"old_timestamp": [NSNumber numberWithDouble:[newLocation.timestamp timeIntervalSince1970]],
                           @"old_speed": [NSNumber numberWithDouble:newLocation.speed],
                           @"old_course": [NSNumber numberWithDouble:newLocation.course],
                           @"old_verticalAccuracy": [NSNumber numberWithDouble:newLocation.verticalAccuracy],
                           @"old_horizontalAccuracy": [NSNumber numberWithDouble:newLocation.horizontalAccuracy],
                           @"old_altitude": [NSNumber numberWithDouble:newLocation.altitude],
                           @"old_latitude": [NSNumber numberWithDouble:newLocation.coordinate.latitude],
                           @"old_longitude": [NSNumber numberWithDouble:newLocation.coordinate.longitude]
                           };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error: nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *jsStatement = [NSString stringWithFormat:@"DGGeofencing.locationMonitorUpdate(%@);", jsonString];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStatement];
}

@end