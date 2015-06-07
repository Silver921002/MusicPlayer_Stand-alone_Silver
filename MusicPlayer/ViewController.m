//
//  ViewController.m
//  MusicPlayer
//
//  Created by HUI on 15/5/31.
//  Copyright (c) 2015年 hui. All rights reserved.
//

#import "ViewController.h"
#import "MusicModel.h"

#define kCellH 30


@interface ViewController ()
{
    BOOL _showSoundView;
    BOOL _showListView;
    BOOL _isPlay;
    
    NSMutableArray *_songArray;
    NSMutableArray *_lrcArray;
    
    AVAudioPlayer *_player;
    
    NSTimer *_timer;
    
    int _songIndex;
    int _lrcIndex;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
    [self createData];
    [self playMusic];
    
    _player.delegate = self;
    
    self.listTableView.contentSize = CGSizeMake(self.listTableView.frame.size.width, kCellH*_songArray.count);
    self.lrcTableView.contentSize = CGSizeMake(self.lrcTableView.frame.size.width, kCellH*_lrcArray.count);
    self.lrcTableView.userInteractionEnabled = NO;
    
    self.soundSlider.value = _player.volume;
    
    self.totalTime.text = [NSString stringWithFormat:@"%02d:%02d", (int)_player.duration/60, (int)_player.duration%60];
   
    
}

#pragma mark - 定时器方法
- (void)timeLabelChange
{
    self.currentTime.text = [NSString stringWithFormat:@"%02d:%02d", (int)_player.currentTime/60, (int)_player.currentTime%60];
    _progressSlider.value = _player.currentTime;
    
    for (_lrcIndex = 0; _lrcIndex<[_lrcArray[_songIndex] count]; _lrcIndex ++)
    {
        NSDictionary *dict = _lrcArray[_songIndex][_lrcIndex];
        if (_player.currentTime >= [dict[@"time"] floatValue])
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_lrcIndex inSection:0];
            UITableViewCell *cell = [_lrcTableView cellForRowAtIndexPath:indexPath];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.textColor = [UIColor orangeColor];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
            [UIView animateWithDuration:0.5 animations:^{
                self.lrcTableView.contentOffset = CGPointMake(0, 44*_lrcIndex);
            }];
            ;
        }
    }
    
}

#pragma mark - 创建视图
- (void)createUI
{
    self.singerImageView.layer.cornerRadius = 10;
    self.singerImageView.layer.borderWidth = 5;
    self.singerImageView.layer.borderColor = [UIColor greenColor].CGColor;
    self.navigationItem.title = @"Music Player";
    self.navigationController.navigationBar.backgroundColor = [UIColor greenColor];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"list"] forState:UIControlStateNormal];
    rightBtn.frame = CGRectMake(0, 0, 30, 30);
    [rightBtn addTarget:self action:@selector(listAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"soundOn"] forState:UIControlStateNormal];
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    [leftBtn addTarget:self action:@selector(soundAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _showSoundView = NO;
    _showListView = NO;
    _isPlay = NO;
    
    _songIndex = 0;
    _lrcIndex = 0;
}

#pragma mark - 创建数据源
- (void)createData
{
    _songArray = [NSMutableArray array];
    _lrcArray = [NSMutableArray array];
    NSArray *songArray = @[@"我可以", @"Call Me Maybe", @"Let It Go", @"表白", @"火花", @"Turn Down for What", @"Heartbeat Song"];
    NSArray *singerArray = @[@"蔡旻佑", @"Carly Rae Jepsen", @"Demi Lovato", @"萧亚轩", @"高太耀", @"DJSnake", @"Kelly Clarkson"];
    for (int i=0; i<songArray.count; i++)
    {
        MusicModel *model = [[MusicModel alloc] init];
        model.name = songArray[i];
        model.type = @"mp3";
        model.imgName = songArray[i];
        model.singer = singerArray[i];
        [_songArray addObject:model];
        
        //解析歌词
        NSString *lrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:songArray[i] ofType:@"lrc"] encoding:NSUTF8StringEncoding error:nil];
        NSArray *sentanceArray = [lrc componentsSeparatedByString:@"\n"];
        NSMutableArray *dictArray = [NSMutableArray array];
        for (NSString *str in sentanceArray)
        {
            NSRange range = [str rangeOfString:@"[0"];
            if (range.length)
            {
                NSArray *array = [str componentsSeparatedByString:@"]"];
                NSString *sentance = array[1];
                NSString *time1 = [array[0] substringFromIndex:1];
                NSArray *timeArray = [time1 componentsSeparatedByString:@":"];
                CGFloat time = [timeArray[0] floatValue]*60 + [timeArray[1] floatValue];
                
                NSDictionary *lrcDict = @{@"time":[NSNumber numberWithFloat:time], @"sentance":sentance};
                [dictArray addObject:lrcDict];
            }
        }
        [_lrcArray addObject:dictArray];
    }
    
    
}

#pragma mark - TableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 1)
    {
        return _songArray.count;
    }
    else
    {
        return [_lrcArray[_songIndex] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1)
    {
        static NSString *listCellId = @"listCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:listCellId];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:listCellId];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        }
        cell.textLabel.text = [_songArray[indexPath.row] name];
        cell.detailTextLabel.text = [_songArray[indexPath.row] singer];
        return cell;
    }
    else
    {
       static NSString *lrcCellId = @"lrcCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:lrcCellId];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:lrcCellId];
            
        }
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.textColor = [UIColor yellowColor];
        cell.textLabel.text = _lrcArray[_songIndex][indexPath.row][@"sentance"];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 2)
    {
        return kCellH;
    }
    return kCellH+10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
    if (tableView.tag == 1)
    {
        _songIndex = (int)indexPath.row;
        [self playMusic];
        [_player play];
        [self listAction];
    }
}

#pragma mark - 视图控件事件方法
- (IBAction)proSliderChange:(UISlider *)sender
{
    _player.currentTime = sender.value;
}

- (IBAction)preAction:(UIButton *)sender
{
    if (_songIndex == 0)
    {
        _songIndex = (int)_songArray.count - 1;
        [self playMusic];
    }
    else
    {
        _songIndex --;
        [self playMusic];
    }

}

- (IBAction)playAction:(UIButton *)sender
{
    if (_isPlay)
    {
        [_player pause];
        self.playBtn.selected = NO;
        _isPlay = NO;
    }
    else
    {
        [_player play];
        self.playBtn.selected = YES;
        _isPlay = YES;
    }
    
}

- (IBAction)nextAction:(UIButton *)sender
{
    if (_songIndex == _songArray.count - 1)
    {
        _songIndex = 0;
        [self playMusic];
        [_player play];
    }
    else
    {
        _songIndex ++;
        [self playMusic];
        [_player play];
    }

}

- (IBAction)soundChange:(UISlider *)sender
{
    _player.volume = sender.value;
}
- (IBAction)soundOffAction:(UIButton *)sender
{
    if (sender.selected)
    {
        _player.volume = _soundSlider.value;
        sender.selected = NO;
    }
    else
    {
        _player.volume = 0;
        sender.selected = YES;
    }
    
    
}

- (void)listAction
{
    [UIView animateWithDuration:0.5 animations:^{
        if (_showListView)
        {
            CGRect temp = self.listTableView.frame;
            temp.origin.x += self.listTableView.frame.size.width;
            self.listTableView.frame = temp;
        }
        else
        {
            CGRect temp = self.listTableView.frame;
            temp.origin.x -= self.listTableView.frame.size.width;
            self.listTableView.frame = temp;
        }
    } completion:^(BOOL finished) {
        _showListView = !_showListView;
    }];
    
}

- (void)soundAction
{
    [UIView animateWithDuration:0.5 animations:^{
        if (_showSoundView)
        {
            CGRect temp = self.soundView.frame;
            temp.origin.y -= self.soundView.frame.size.height;
            self.soundView.frame = temp;
        }
        else
        {
            CGRect temp = self.soundView.frame;
            temp.origin.y += self.soundView.frame.size.height;
            self.soundView.frame = temp;
        }
        
    } completion:^(BOOL finished) {
        _showSoundView = !_showSoundView;
    }];
}

#pragma mark - 播放音乐
- (void)playMusic
{
    MusicModel *music = _songArray[_songIndex];
    _player = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:music.name ofType:music.type]] error:nil];
    self.progressSlider.maximumValue = _player.duration;
    self.nameLabel.text = [NSString stringWithFormat:@"%@--%@", music.name, music.singer];
    self.singerImageView.image = [UIImage imageNamed:music.imgName];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(timeLabelChange) userInfo:nil repeats:YES];
    _lrcIndex = 0;
    [_lrcTableView reloadData];

}

#pragma mark - AVAudioPlayer代理方法
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (_player == player && flag == YES)
    {
        if (_songIndex == _songArray.count - 1)
        {
            _songIndex = 0;
            [self playMusic];
            [_player play];
        }
        else
        {
            _songIndex ++;
            [self playMusic];
            [_player play];
        }
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
