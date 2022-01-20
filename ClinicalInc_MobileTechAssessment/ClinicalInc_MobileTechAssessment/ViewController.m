//
//  ViewController.m
//  ClinicalInc_MobileTechAssessment
//
//  Created by user206074 on 12/27/21.
//

#import "ViewController.h"
@import CoreLocation;
@import GoogleMaps;

@interface ViewController () <CLLocationManagerDelegate, GMSMapViewDelegate>
@property (strong, nonatomic) IBOutlet GMSMapView *MapView;
@property (weak, nonatomic) IBOutlet UILabel *LocationCoordLabel;
@property (weak, nonatomic) IBOutlet UILabel *LocationNameLabel;
@property (weak, nonatomic) IBOutlet UISlider *ZoomValue;

- (IBAction)ZoomValueChanged:(id)sender;

@end

@implementation ViewController {
    CLLocationManager *locationManager;
    CLLocation * _Nullable currentLocation;
    float defaultZoomLevel;
    GMSGeocoder *geocoder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    defaultZoomLevel = 15.0;

    // Initialize the location manager.
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestWhenInUseAuthorization];
    locationManager.distanceFilter = 50;
    [locationManager startUpdatingLocation];
    locationManager.delegate = self;

    //set initial zoom level
    [self.ZoomValue setValue:defaultZoomLevel];
    //set up initial map view
    self.MapView.delegate = self;
    self.MapView.settings.myLocationButton = YES;
    self.MapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.MapView.myLocationEnabled = YES;
    
}

-(GMSCameraPosition*)updateCamera:(CLLocationCoordinate2D)coordinates{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinates.latitude longitude:coordinates.longitude zoom:self.ZoomValue.value];
    NSLog(@"CAMERA UPDATE!%@", camera);
    return camera;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = locations.lastObject;
    NSLog(@"Location: %@", location);

    GMSCameraPosition *camera = [self updateCamera:location.coordinate];
    self.MapView.camera = camera;
    [self.MapView animateToCameraPosition:camera];
}

-(void)updateLabelText:(CLLocationCoordinate2D)coordinates{
    [self.LocationCoordLabel setText:[NSString stringWithFormat:@"Current Location: (%@, %@)", [NSNumber numberWithFloat:coordinates.latitude], [NSNumber numberWithFloat:coordinates.longitude]]];
    [self getLocationAddress:coordinates];
}


-(void)getLocationAddress:(CLLocationCoordinate2D)coordinates{
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:coordinates completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
        NSLog(@"reverse geocoding results:");
        for(GMSAddress* addressObj in [response results]){
            if (addressObj.thoroughfare != NULL) {
                [self.LocationNameLabel setText:[NSString stringWithFormat:@"%@, %@, %@, %@", addressObj.thoroughfare, addressObj.locality, addressObj.administrativeArea, addressObj.postalCode]];
                break;
            }
        }
    }];
}
-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(nonnull GMSCameraPosition *)position{
    NSLog(@"Camera Idle At @%", position.target);
    [self updateLabelText:position.target];
}

-(void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager
{
    switch (manager.accuracyAuthorization) {
        case CLAccuracyAuthorizationFullAccuracy:
            NSLog(@"Location accuracy is precise.");
            break;
        case CLAccuracyAuthorizationReducedAccuracy:
            NSLog(@"Location accuracy is not precise.");
            break;
    }
    
    switch (manager.authorizationStatus) {
      case kCLAuthorizationStatusRestricted:
        NSLog(@"Location access was restricted.");
        break;
      case kCLAuthorizationStatusDenied:
        NSLog(@"User denied access to location.");
            break;
      case kCLAuthorizationStatusNotDetermined:
        NSLog(@"Location status not determined.");
            break;
      case kCLAuthorizationStatusAuthorizedAlways:
      case kCLAuthorizationStatusAuthorizedWhenInUse:
        NSLog(@"Location status is OK.");

            break;
    }
  }

  // Handle location manager errors.
  - (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
  {
    [manager stopUpdatingLocation];
    NSLog(@"Error: %@", error.localizedDescription);
  }

- (IBAction)ZoomValueChanged:(id)sender {
    [self.MapView animateToZoom:self.ZoomValue.value];
    
}
@end
