//
//  GIVideoPickerViewController.m
//  VRMicro
//
//  Created by kegebai on 2018/5/8.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIVideoPickerViewController.h"
#import "GIVideoPickerTCell.h"
#import "GIVideoItem.h"

static const CGFloat GIVideoItemRowHeight = 24.f;

@interface GIVideoPickerViewController ()
@property (nonatomic, copy) NSArray<GIVideoItem *> *videoItems;
// flag of initial load
@property (nonatomic) BOOL isInitialItemLoad;
@end

@implementation GIVideoPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.isInitialItemLoad = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GIVideoPickerTCell *cell = [tableView dequeueReusableCellWithIdentifier:[GIVideoPickerTCell giid]
                                                               forIndexPath:indexPath];
    // Configure the cell...
    if (!cell) {
        cell = [[GIVideoPickerTCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:[GIVideoPickerTCell giid]];
        [cell.playButton addTarget:self
                            action:@selector(handlePreviewTap:)
                  forControlEvents:UIControlEventTouchUpInside];
        [cell.addButton  addTarget:self
                            action:@selector(addMediaItemTap:)
                  forControlEvents:UIControlEventTouchUpInside];
    }
    [cell bindData:self.videoItems[indexPath.row]];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return GIVideoItemRowHeight;
}

#pragma mark - action

- (void)handlePreviewTap:(UIButton *)button {
    NSIndexPath *indexPath = GIIndexPathForButton(self.tableView, button);
    if (!button.selected) {
        GIVideoItem *item = self.videoItems[indexPath.row];
        [self.playbackMediator previewMediaItem:item];
    } else {
        [self.playbackMediator stopPlayback];
    }
    button.selected = !button.selected;
}

- (void)addMediaItemTap:(UIButton *)button {
    NSIndexPath *indexPath = GIIndexPathForButton(self.tableView, button);
    GIVideoItem *item = self.videoItems[indexPath.row];
    [self.playbackMediator addMediaItem:item toTimelineTrack:GIVideoTrack];
}

#pragma mark - getter

- (NSArray<GIVideoItem *> *)defaultVideoItems {
    return [[self.videoItems copy] subarrayWithRange:NSMakeRange(0, 3)];
}

- (NSArray<GIVideoItem *> *)videoItems {
    if (!_videoItems) {
        // TODO: ... To be implementation add urls from asset library
        NSMutableArray<NSURL *> *urls = [NSMutableArray array];
        [urls addObjectsFromArray:[[NSBundle mainBundle] URLsForResourcesWithExtension:@"mov" subdirectory:nil]];
        [urls addObjectsFromArray:[[NSBundle mainBundle] URLsForResourcesWithExtension:@"mp4" subdirectory:nil]];
        NSMutableArray<GIVideoItem *> *items = [NSMutableArray array];
        for (int i = 0; i < urls.count; i++) {
            GIVideoItem *item = [GIVideoItem videoItemWithURL:urls[i]];
            [item prepare:^(BOOL complete) {
                if (complete) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (i == 0 && !self.isInitialItemLoad) {
                            self.isInitialItemLoad = YES;
                            [self.playbackMediator loadMediaItem:item];
                        }
                        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]
                                              withRowAnimation:UITableViewRowAnimationNone];
                    });
                }
            }];
            [items addObject:item];
        }
        _videoItems = items;
    }
    return _videoItems;
}

@end
