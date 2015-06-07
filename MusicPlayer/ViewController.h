//
//  ViewController.h
//  MusicPlayer
//
//  Created by HUI on 15/5/31.
//  Copyright (c) 2015年 hui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *singerImageView;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UISlider *soundSlider;
- (IBAction)soundOffAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *soundView;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (weak, nonatomic) IBOutlet UITableView *lrcTableView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *currentTime;
@property (weak, nonatomic) IBOutlet UILabel *totalTime;

- (IBAction)proSliderChange:(UISlider *)sender;
- (IBAction)preAction:(UIButton *)sender;
- (IBAction)playAction:(UIButton *)sender;
- (IBAction)nextAction:(UIButton *)sender;
- (IBAction)soundChange:(UISlider *)sender;


@end

