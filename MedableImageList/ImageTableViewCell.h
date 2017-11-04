//
//  ImageTableViewCell.h
//  MedableImageList
//
//  Created by Fiachra Matthews on 03/11/2017.
//  Copyright © 2017 Fiachra Matthews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *PreviewImage;
@property (weak, nonatomic) IBOutlet UILabel *ImageTitle;
@property (weak, nonatomic) IBOutlet UILabel *ImageDescription;

@end
