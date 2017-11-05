//
//  DetailViewController.m
//  MedableImageList
//
//  Created by Fiachra Matthews on 03/11/2017.
//  Copyright © 2017 Fiachra Matthews. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        NSString *imageThumb = [[self.detailItem objectForKey:@"urls"] objectForKey:@"regular"];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageThumb]];
        self.detalImage.image = [UIImage imageWithData:imageData];
        
        NSString* username = @"None";
        NSString* description = @"None";
        NSString* created = @"None";
        
        id Value = [[self.detailItem objectForKey:@"user"] objectForKey:@"name"];
        if (Value != [NSNull null]) {
            username = (NSString *)Value;
        }
        
        Value = [self.detailItem objectForKey:@"description"];
        if (Value != [NSNull null]) {
            description = (NSString *)Value;
        }
        
        Value = [self.detailItem objectForKey:@"created_at"];
        if (Value != [NSNull null]) {
            created = (NSString *)Value;
        }
        
        self.detailUsername.text = username;
        self.detailDescription.text = description;
        self.detailCreated.text = created;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Managing the detail item

- (void)setDetailItem:(NSDictionary *)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}


- (IBAction)saveImage:(id)sender {
    
    if(self.detailItem){
        NSString *imageUrl = [[self.detailItem objectForKey:@"urls"] objectForKey:@"regular"];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:imageData] ,nil,nil,nil);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Medable Images"
                                                        message:@"This image has been saved"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
   
    
}
@end
