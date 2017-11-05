//
//  DetailViewController.h
//  MedableImageList
//
//  Created by Fiachra Matthews on 03/11/2017.
//  Copyright © 2017 Fiachra Matthews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSDictionary *detailItem;

@property (weak, nonatomic) IBOutlet UIImageView *detalImage;
@property (weak, nonatomic) IBOutlet UILabel *detailUsername;
@property (weak, nonatomic) IBOutlet UILabel *detailDescription;
@property (weak, nonatomic) IBOutlet UILabel *detailCreated;

- (IBAction)saveImage:(id)sender;

@end

