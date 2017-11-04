//
//  MasterViewController.m
//  MedableImageList
//
//  Created by Fiachra Matthews on 03/11/2017.
//  Copyright © 2017 Fiachra Matthews. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "ImageTableViewCell.h"

@interface MasterViewController () <UISearchDisplayDelegate, UISearchBarDelegate>

@property NSMutableArray *objects;

-(void)updateTableData;

@end

@implementation MasterViewController{
    int _pageNumber;
    NSString *_searchTerm;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    _pageNumber = 1;
    _searchTerm = @"cow";
    
    [self updateTableData];
    
}


- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    NSString *ImageURL = @"https://images.unsplash.com/photo-1454179083322-198bb4daae41?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=200&fit=max&s=970044d23cedaac1ebfeca35f8eddbcc";
    
    [self.objects insertObject:ImageURL atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) updateTableData{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.unsplash.com/search/photos/?client_id=d57506fcfc106f75b2c01e4d4fce445d330346461610e3879335ebdffeb9c79d&per_page=25&query=%@&page=%", _searchTerm, _pageNumber]]];
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"Request reply: %@", requestReply);
        
        if (!self.objects) {
            self.objects = [[NSMutableArray alloc] init];
        }
        
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSArray* results = [json objectForKey:@"results"];
        
        for (NSDictionary *res in results ){
            [self.objects insertObject:res atIndex:0];
        }
        //NSLog(self.objects.count);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }] resume];
}
#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     ImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
     NSLog([NSString stringWithFormat:@"Table Row:%d", indexPath.row]);

    //NSDate *object = self.objects[indexPath.row];
    NSDictionary *image = self.objects[indexPath.row];
    NSString *imageThumb = [[image objectForKey:@"urls"] objectForKey:@"thumb"];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageThumb]];
    cell.PreviewImage.image = [UIImage imageWithData:imageData];
    
    NSString* username = [[image objectForKey:@"user"] objectForKey:@"name"];
    NSString* description = @"";
    
    if([image objectForKey:@"description"])
        description = [image objectForKey:@"description"];
    
    cell.ImageTitle.text = username;
    cell.ImageDescription.text = @"Fffffffffffffffffffffffffffff";
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110.0;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        //end of loading
        //for example [activityIndicator stopAnimating];

        _pageNumber++;
     
    }
}

@end
