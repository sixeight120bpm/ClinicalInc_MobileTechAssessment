//
//  ViewController.m
//  ClinicalInc_MobileTechAssessment
//
//  Created by user206074 on 12/27/21.
//

#import "ViewController.h"
@import CoreLocation;
@import GoogleMaps;
@import MapKit;

@interface ViewController () <CLLocationManagerDelegate, GMSMapViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet GMSMapView *MapView;
@property (weak, nonatomic) IBOutlet UILabel *LocationCoordLabel;
@property (weak, nonatomic) IBOutlet UILabel *LocationNameLabel;
@property (weak, nonatomic) IBOutlet UISlider *ZoomValue;
@property (weak, nonatomic) IBOutlet UISearchBar *AddressSearch;
- (IBAction)ZoomValueChanged:(id)sender;

@end

@implementation ViewController {
    CLLocationManager *locationManager;
    CLLocation * _Nullable currentLocation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLocationManager];
    [self configureMapView];
}

-(void)configureLocationManager{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestWhenInUseAuthorization];
    locationManager.distanceFilter = 50;
    locationManager.delegate = self;
}

-(void)configureMapView{
    self.MapView.delegate = self;
    self.MapView.settings.myLocationButton = YES;
    self.MapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.MapView.myLocationEnabled = YES;
}

-(void)updateCamera:(CLLocationCoordinate2D)coordinates{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinates.latitude longitude:coordinates.longitude zoom:self.ZoomValue.value];
    self.MapView.camera = camera;
    [self.MapView animateToCameraPosition:camera];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = locations.lastObject;
    [self updateCamera:location.coordinate];
}

-(void)updateLabelText:(CLLocationCoordinate2D)coordinates{
    [self.LocationCoordLabel setText: [self formatCoordinateString:coordinates]];
    [self getLocationAddress:coordinates];
}

-(NSString*)formatCoordinateString:(CLLocationCoordinate2D)coordinates{
    return [NSString stringWithFormat:@"Current Location: (%@, %@)", [NSNumber numberWithFloat:coordinates.latitude], [NSNumber numberWithFloat:coordinates.longitude]];
}

-(void)getLocationAddress:(CLLocationCoordinate2D)coordinates{
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:coordinates completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
        for(GMSAddress* addressObj in [response results]){
            if (addressObj.thoroughfare != NULL) {
                [self.LocationNameLabel setText:[NSString stringWithFormat:@"%@, %@, %@, %@", addressObj.thoroughfare, addressObj.locality, addressObj.administrativeArea, addressObj.postalCode]];
                break;
            }
        }
    }];
}

-(void)getLocationCoordsFromAddress:(NSString *)address{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            [self updateCamera:placemark.location.coordinate];
        }];
}

-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(nonnull GMSCameraPosition *)position{
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
            [locationManager startUpdatingLocation];
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

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self getLocationCoordsFromAddress:searchBar.text];
    [searchBar resignFirstResponder];
}
@end
