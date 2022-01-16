//
//  MapViewController.h
//  ClinicalInc_MobileTechAssessment
//
//  Created by user206074 on 1/15/22.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapInfo.h"

@interface MapViewController : UIViewController <CLLocationManagerDelegate>
@property (weak, nonatomic) MapInfo *mapInfo;

@end
