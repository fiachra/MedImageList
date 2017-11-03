//
//  DetailViewController.h
//  MedableImageList
//
//  Created by Fiachra Matthews on 03/11/2017.
//  Copyright © 2017 Fiachra Matthews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSDate *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

