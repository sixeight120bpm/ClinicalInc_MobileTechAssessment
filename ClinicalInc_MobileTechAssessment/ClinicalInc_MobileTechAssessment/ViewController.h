//
//  ViewController.h
//  ClinicalInc_MobileTechAssessment
//
//  Created by user206074 on 12/27/21.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapInfo.h"
@interface ViewController : UIViewController <CLLocationManagerDelegate> 
@property (nonatomic, assign) NSString *locationName;
@property (nonatomic, assign) NSString *locationCoords;

@end

