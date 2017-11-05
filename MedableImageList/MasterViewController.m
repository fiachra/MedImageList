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

@interface MasterViewController () <UISearchBarDelegate>

@property NSMutableArray *objects;
@property NSMutableArray *selectedObjects;

-(void)updateTableData;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation MasterViewController{
    int _pageNumber;
    NSString *_searchTerm;
    int _searchReturnPages;
    BOOL _loading;
    BOOL _selecting;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.leftBarButtonItem.title = @"Select";
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    _pageNumber = 1;
    _searchTerm = @"";
    _loading = false;
    _selecting = false;
    
    self.searchBar.delegate = self;
    
    
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if(editing == YES)
    {
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveImages:)];
        self.navigationItem.rightBarButtonItem = saveButton;
        _selecting = true;
        // Your code for entering edit mode goes here
    } else {
       
        [self.selectedObjects removeAllObjects];
        
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem.title = @"Select";
        _selecting = false;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)saveImages:(id)sender {
    
    [self addActivityIndicator];
    for (NSDictionary *res in self.selectedObjects ){
        NSString *imageUrl = [[res objectForKey:@"urls"] objectForKey:@"regular"];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:imageData] ,nil,nil,nil);
        
    }
    
    [self removeActivityIndicator];
    [super setEditing:false animated:true];
    self.navigationItem.rightBarButtonItem = nil;
    _selecting = false;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Medable Images"
                                                    message:@"Images Saved"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}

-(void) addActivityIndicator
{
    int overlayWidth = self.view.frame.size.width * 1.1;
    int overlayHeight = self.view.frame.size.height * 1.1;
    
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(round((self.view.frame.size.width-overlayWidth) / 2), round((self.view.frame.size.height-overlayHeight) / 2), overlayWidth, overlayHeight)];
    backgroundView.tag = 1;
    [backgroundView.layer setCornerRadius:5.0f];
    [backgroundView.layer setBorderWidth:2.0f];
    [backgroundView.layer setBorderColor:[UIColor blackColor].CGColor];
    [backgroundView setBackgroundColor:[UIColor blackColor]];
    [backgroundView setAlpha:0.5f];
    
    UIActivityIndicatorView *av = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    av.frame = CGRectMake(round((backgroundView.frame.size.width - 25) / 2), round((backgroundView.frame.size.height - 25) / 2), 25, 25);
    av.tag  = 1;
    [backgroundView addSubview:av];
    [self.view addSubview:backgroundView];
    [av startAnimating];
}

-(void) removeActivityIndicator
{
    UIView *tmpimg = (UIView *)[self.view viewWithTag:1];
    [tmpimg removeFromSuperview];
}

- (void) updateTableData{
    _loading = true;
    [self addActivityIndicator];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.unsplash.com/search/photos/?client_id=d57506fcfc106f75b2c01e4d4fce445d330346461610e3879335ebdffeb9c79d&per_page=25&query=%@&page=%d", [_searchTerm stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]], _pageNumber]]];
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        //NSLog(@"Request reply: %@", requestReply);
        
        if (!self.objects) {
            self.objects = [[NSMutableArray alloc] init];
        }
        
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSArray* results = [json objectForKey:@"results"];
        _searchReturnPages = (int)[json valueForKey:@"total_pages"];
        
        for (NSDictionary *res in results ){
            [self.objects addObject:res];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self removeActivityIndicator];
            _loading = false;
            
        });
        
    }] resume];
}
#pragma mark - Segues

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return !_selecting;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}


#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.selectedObjects ) {
        self.selectedObjects = [[NSMutableArray alloc] init];
    }
    
    [self.selectedObjects addObject:self.objects[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [self.selectedObjects removeObject:self.objects[indexPath.row]];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     ImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSDictionary *image = self.objects[indexPath.row];
    
    
    id Value = [[image objectForKey:@"urls"] objectForKey:@"thumb"];
    NSString *imageThumb = @"";
    if (Value != [NSNull null]) {
        imageThumb = (NSString *)Value;
    }
    
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageThumb]];
    cell.PreviewImage.image = [UIImage imageWithData:imageData];
    cell.PreviewImage.layer.cornerRadius = 20;
    cell.PreviewImage.clipsToBounds = YES;
    
    NSString* username = @"None";//[[image objectForKey:@"user"] objectForKey:@"name"];
    NSString* description = @"None";
    
    Value = [[image objectForKey:@"user"] objectForKey:@"name"];
    if (Value != [NSNull null]) {
        username = (NSString *)Value;
    }

    Value = [image objectForKey:@"description"];
    if (Value != [NSNull null]) {
        description = (NSString *)Value;
    }
    
    cell.ImageTitle.text = username;
    cell.ImageDescription.text = description;
    
    if(indexPath.row == self.objects.count-1 && !_loading)
    {
        if(_searchReturnPages > _pageNumber)
        {
            _pageNumber++;
            [self updateTableData];
        }
    }
    
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

#pragma mark - Search delegate methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    _pageNumber = 1;
    _searchTerm = searchBar.text;
    [self.objects removeAllObjects];
    
    [self updateTableData];
}
@end
