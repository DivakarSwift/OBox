//
//  GIAudioPickerViewController.m
//  VRMicro
//
//  Created by kegebai on 2018/5/8.
//  Copyright © 2018年 kegebai. All rights reserved.
//

#import "GIAudioPickerViewController.h"
#import "GIAudioSessionHeaderView.h"
#import "GIAudioPickerTCell.h"
#import "GIAudioItem.h"

static const CGFloat HeaderHeight = 34.f;

@interface GIAudioPickerViewController ()
@property (nonatomic, copy) NSArray *audioItems;
@property (nonatomic, copy) NSArray<GIAudioItem *> *musicItems;
@property (nonatomic, copy) NSArray<GIAudioItem *> *voiceOverItems;
@property (nonatomic) BOOL isPreviewComplete;
@end

@implementation GIAudioPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePreviewComplete:)
                                                 name:GIPlaybackCompleteNotification
                                               object:nil];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.audioItems = @[
        self.musicItems,
        self.voiceOverItems
    ];
    self.isPreviewComplete = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.audioItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.audioItems[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GIAudioPickerTCell *cell = [tableView dequeueReusableCellWithIdentifier:[GIAudioPickerTCell giid]
                                                               forIndexPath:indexPath];
    // Configure the cell...
    if (!cell) {
        cell = [[GIAudioPickerTCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:[GIAudioPickerTCell giid]];
        [cell.playButton addTarget:self
                            action:@selector(handlePlayTap:)
                  forControlEvents:UIControlEventTouchUpInside];
    }
    [cell bindData:self.audioItems[indexPath.section][indexPath.row]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? @"Music" : @"Voice Overs";
}

#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    GIAudioSessionHeaderView *header = [[GIAudioSessionHeaderView alloc]
                                        initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, HeaderHeight)];
    [header bindData:[self tableView:tableView titleForHeaderInSection:section]];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HeaderHeight;
}

#pragma mark - action

- (void)handlePreviewComplete:(NSNotification *)notification {
    self.isPreviewComplete = YES;
    [self.tableView reloadData];
}

- (void)handlePlayTap:(UIButton *)button {
    NSIndexPath *indexPath = GIIndexPathForButton(self.tableView, button);
    if (!button.selected) {
        GIMediaItem *item = indexPath.section == 0 ? self.musicItems[indexPath.row] : self.voiceOverItems[indexPath.row];
        [self.playbackMediator previewMediaItem:item];
    } else {
        [self.playbackMediator stopPlayback];
    }
    button.selected = !button.selected;
}

#pragma mark - getter

- (GIAudioItem *)defaultVioceOver {
    return [[self.voiceOverItems copy] firstObject];
}

- (GIAudioItem *)defaultMusicTrack {
    return [[self.musicItems copy] firstObject];
}

- (NSArray<GIAudioItem *> *)voiceOverItems {
    if (!_voiceOverItems) {
        // TODO: ... To be implementation add urls from asset library
        NSArray<NSURL *> *voiceOverUrls = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"m4a" subdirectory:@"VoiceOvers"];
        NSMutableArray<GIAudioItem *> *items = [NSMutableArray array];
        for (int i = 0; i < voiceOverUrls.count; i++) {
            GIAudioItem *item = [GIAudioItem audioItemWithURL:voiceOverUrls[i]];
            [item prepare:NULL];
            [items addObject:item];
        }
        _voiceOverItems = items;
    }
    return _voiceOverItems;
}

- (NSArray<GIAudioItem *> *)musicItems {
    if (!_musicItems) {
        // TODO: ... To be implementation add urls from asset library
        NSArray<NSURL *> *musicItems = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"m4a" subdirectory:@"Music"];
        NSMutableArray<GIAudioItem *> *items = [NSMutableArray array];
        for (int i = 0; i < musicItems.count; i++) {
            GIAudioItem *item = [GIAudioItem audioItemWithURL:musicItems[i]];
            [item prepare:NULL];
            [items addObject:item];
        }
        _musicItems = items;
    }
    return _musicItems;
}

@end
