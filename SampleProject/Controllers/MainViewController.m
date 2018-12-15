#import "MainViewController.h"
#import "ListCell.h"
#import "ListObject.h"
#import "FirstViewController.h"
#import "FavoriteChangeHandling.h"

@interface MainViewController ()<UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate,  UITableViewDelegate, UITableViewDataSource,FavoriteChangeHandling>

@property(strong, nonatomic) NSMutableArray *objectArray;
@property(nonatomic,strong) NSArray *searchResults;
@property(strong, nonatomic) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (strong, nonatomic) NSString* searchText;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Universities List";
    [self configureSearchController];
    
    self.favoriteObjects = [NSMutableSet new];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(pullToRefresh:) forControlEvents:UIControlEventValueChanged];
    refreshControl.backgroundColor = [UIColor purpleColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [self.tableView addSubview:refreshControl];
    
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)pullToRefresh:(UIRefreshControl *)refreshControl
{
    [self loadDataWithSearchText];
    [refreshControl endRefreshing];
}

- (void)configureSearchController {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
}

- (void)loadDataWithSearchText  {
    __block typeof(self) weakSelf = self;
    NSString *str = [NSString stringWithFormat:@"http://universities.hipolabs.com/search?name=%@",
                     self.searchText];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *url = [NSURL URLWithString:str];
    
    if (url == nil) {
        [self showErrorAlertViewWithErrorString:@"url error"];
        return;
    }
    
    [self.activityIndicatorView startAnimating];
    
    if (self.dataTask != nil && [self.dataTask state] == NSURLSessionTaskStateRunning) {
        [self.dataTask cancel];
    }
    
    self.dataTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            if ([error code] != NSURLErrorCancelled) {
                [weakSelf showErrorAlertViewWithErrorString:[error localizedDescription]];
                return;
            }
            else {
                return;
            }
        }
        
        if (response != nil && data != nil && [data length] > 0) {
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if ([httpResponse statusCode] == 200) {
                NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                if (error != nil) {
                    [weakSelf showErrorAlertViewWithErrorString:[error localizedDescription]];
                    return;
                }
                weakSelf.objectArray = [NSMutableArray new];
                
                for (NSDictionary *dic in dataDictionary){
                    ListObject *listObject = [[ListObject alloc] init];
                    listObject.country  = [dic objectForKey:@"country"];
                    listObject.universityName  = [dic objectForKey:@"name"];
                    listObject.domainName = [[dic objectForKey:@"domains"]objectAtIndex:0 ];
                    listObject.webPageUrlString = [[dic objectForKey:@"web_pages"]objectAtIndex:0 ];
                    
                    [weakSelf.objectArray addObject:listObject];
                }
                weakSelf.searchResults = weakSelf.objectArray;
                
                for (ListObject *object in self.favoriteObjects) {
                    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                        
                        ListObject *listObject = (ListObject*)evaluatedObject;
                        if ([listObject.universityName isEqualToString:object.universityName] ) {
                            return YES;
                        }
                        return NO;
                    }];
                    NSArray *results = [weakSelf.searchResults filteredArrayUsingPredicate:predicate];
                    for (ListObject *object in results) {
                        object.isFavorite = YES;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.activityIndicatorView stopAnimating];
                    [weakSelf.tableView reloadData];
                });
            }
            else {
                [weakSelf showErrorAlertViewWithErrorString:@"something went wrong here"];
            }
        }
        else {
            if (error != nil) {
                [weakSelf showErrorAlertViewWithErrorString:@"something went wrong here"];
                return;
            }
        }
    }];
    [self.dataTask resume];
}

#pragma mark - Table view data source -

- (void) showErrorAlertViewWithErrorString:(NSString*)errorString {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Error occurred - %@", errorString);
        });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reusableIdentifier = [ListCell reusableIdentifier];
    ListCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableIdentifier
                                                     forIndexPath:indexPath];
    
    ListObject *currentObject =[self.searchResults objectAtIndex:indexPath.row];
    cell.listObject = currentObject;
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        ListObject *object = (ListObject*)evaluatedObject;
        return ([[evaluatedObject universityName] isEqualToString:currentObject.universityName] && object.isFavorite);
    }];
    NSSet *favoriteObject = [self.favoriteObjects filteredSetUsingPredicate:predicate];
    
    if ([favoriteObject count] > 0) {
        cell.favButton.hidden = NO;
    }
    else {
        cell.favButton.hidden = YES;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *imageStr = [NSString stringWithFormat:@"https://logo.clearbit.com/%@",
                              currentObject.domainName];
        NSURL *url = [NSURL URLWithString:imageStr];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [[UIImage alloc]initWithData:data];
        currentObject.imageData = data;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image != nil) {
                cell.cellImageView.image = image;
            }
            else{
                cell.cellImageView.image = [UIImage imageNamed:@"Default_University"];
            }
        });
    });
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FirstViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstViewController"];
    vc.myCustomObjectToPass = [self.searchResults objectAtIndex:indexPath.row];
    vc.favouriteProtocol = self;
    [self.navigationController pushViewController:vc animated:true];
}
- (NSMutableArray *)objectArray {
    if ( _objectArray == nil) {
        _objectArray = [[NSMutableArray alloc]init];
    }
    return _objectArray;
}

#pragma mark - FavoriteChangeHandling methods implementation -

- (void) favouriteChangedStatusWithObject:(ListObject*)listObject {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"universityName == %@",listObject.universityName ];
    NSSet *objects = [self.favoriteObjects filteredSetUsingPredicate:predicate];
    
    BOOL removeObject = !listObject.isFavorite;
    if ([objects  count] == 0 && listObject.isFavorite) {
        [self.favoriteObjects addObject:listObject];
    }
    else {
        for (ListObject *object in objects) {
            if (removeObject)
                [self.favoriteObjects removeObject:object];
            
            else {
                [self.favoriteObjects addObject:object];
            }
        }
    }
}

#pragma mark UISearchControllerDelegate -
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    self. searchText = searchController.searchBar.text;
    if  ( [self.searchText length] > 0) {
        [self loadDataWithSearchText];
    }
    else {
        self.searchResults = nil;
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.searchController];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchResults = self.objectArray;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}
@end
