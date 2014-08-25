//
//  XHDemoWeChatMessageTableViewController.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-27.
//  Copyright (c) 2014年 蒲剑 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "AppDelegate.h"
#import "XHPopMenu.h"

#import "XHDisplayTextViewController.h"
#import "XHDisplayMediaViewController.h"
#import "XHDisplayLocationViewController.h"

#import "XHContactDetailTableViewController.h"
#import "XHAudioPlayerHelper.h"
#import "NSMutableAttributedString+Helper.h"


#import "SBJsonParser.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Toast+UIView.h"

#import "BTApplication.h"
#import "MessageTools.h"
#import "VoiceTools.h"
#import "ImageTools.h"
#import "REMenu.h"

#import "BTChatMessageTableViewController.h"

@interface BTChatMessageTableViewController () <XHAudioPlayerHelperDelegate>

@property (nonatomic, strong) NSArray *emotionManagers;

@property (nonatomic, strong) XHMessageTableViewCell *currentSelectedCell;

@property (nonatomic, strong) XHPopMenu *popMenu;



@end

@implementation BTChatMessageTableViewController

Boolean _isLoading;


NSMutableArray *_faceArray; // 表情数据 蒲剑;
UIImage *_upload_image_temp; // 临时保存上传图片 蒲剑;
NSString *_upload_imagefilename_temp; // 临时保存上传图片 蒲剑;
UIDocumentInteractionController *documentController; //第三方应用交互控件 蒲剑

- (XHMessage *)getTextMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    XHMessage *textMessage = [[XHMessage alloc] initWithText:@"Call Me 13002994107. 这里是事务通，如果大家喜欢这个，请帮帮忙支持一下哈！" sender:@"老蒲" timestamp:[NSDate distantPast]];
    textMessage.avator = [UIImage imageNamed:@"avator"];
    textMessage.avatorUrl = @"http://tp2.sinaimg.cn/1966395317/180/5606145763/1";
    textMessage.bubbleMessageType = bubbleMessageType;
    
    return textMessage;
}

- (XHMessage *)getPhotoMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    XHMessage *photoMessage = [[XHMessage alloc] initWithPhoto:[UIImage imageNamed:@"placeholderImage"] thumbnailUrl:@"http://tp2.sinaimg.cn/1966395317/180/5606145763/1" originPhotoUrl:nil sender:@"Skynet" timestamp:[NSDate date]];
    photoMessage.avator = [UIImage imageNamed:@"avator"];
    photoMessage.avatorUrl = @"http://tp2.sinaimg.cn/1966395317/180/5606145763/1";
    photoMessage.bubbleMessageType = bubbleMessageType;
    
    return photoMessage;
}

- (XHMessage *)getVideoMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"IMG_1555.MOV" ofType:@""];
    XHMessage *videoMessage = [[XHMessage alloc] initWithVideoConverPhoto:[XHMessageVideoConverPhotoFactory videoConverPhotoWithVideoPath:videoPath] videoPath:videoPath videoUrl:nil sender:@"Jayson" timestamp:[NSDate date]];
    videoMessage.avator = [UIImage imageNamed:@"avator"];
    videoMessage.avatorUrl = @"http://tp2.sinaimg.cn/1966395317/180/5606145763/1";
    videoMessage.bubbleMessageType = bubbleMessageType;
    
    return videoMessage;
}

- (XHMessage *)getVoiceMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    XHMessage *voiceMessage = [[XHMessage alloc] initWithVoicePath:nil voiceUrl:nil voiceDuration:@"1" sender:@"Jayson" timestamp:[NSDate date]];
    voiceMessage.avator = [UIImage imageNamed:@"avator"];
    voiceMessage.avatorUrl = @"http://tp2.sinaimg.cn/1966395317/180/5606145763/1";
    voiceMessage.bubbleMessageType = bubbleMessageType;
    
    return voiceMessage;
}

- (XHMessage *)getEmotionMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    XHMessage *emotionMessage = [[XHMessage alloc] initWithEmotionPath:[[NSBundle mainBundle] pathForResource:@"emotion1.gif" ofType:nil] sender:@"Jayson" timestamp:[NSDate date]];
    emotionMessage.avator = [UIImage imageNamed:@"avator"];
    emotionMessage.avatorUrl = @"http://tp2.sinaimg.cn/1966395317/180/5606145763/1";
    emotionMessage.bubbleMessageType = bubbleMessageType;
    
    return emotionMessage;
}

- (XHMessage *)getGeolocationsMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    XHMessage *localPositionMessage = [[XHMessage alloc] initWithLocalPositionPhoto:[UIImage imageNamed:@"Fav_Cell_Loc"] geolocations:@"中国广东省广州市天河区东圃二马路121号" location:[[CLLocation alloc] initWithLatitude:23.110387 longitude:113.399444] sender:@"Jack" timestamp:[NSDate date]];
    localPositionMessage.avator = [UIImage imageNamed:@"avator"];
    localPositionMessage.avatorUrl = @"http://tp2.sinaimg.cn/1966395317/180/5606145763/1";
    localPositionMessage.bubbleMessageType = bubbleMessageType;
    
    return localPositionMessage;
}

- (void)showMenuOnView:(UIBarButtonItem *)buttonItem {
    
    // 加载标题右侧下拉菜单栏
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    int ctype = [(NSNumber *)[delegate._chatmessage_topic objectForKey:@"type"] intValue];
    
    switch (ctype)
    {
        case BTTopicTypeMeeting:
        {
            [self.popMenu_meeting showMenuOnView:self.view atPoint:CGPointZero];
            break;
        }
        case BTTopicTypeTask:
        {
            [self.popMenu_task showMenuOnView:self.view atPoint:CGPointZero];
            break;
        }
        default:
            break;
    }
    
}

- (XHPopMenu *)popMenu_meeting {
    if (!_popMenu) {
        NSMutableArray *popMenuItems = [[NSMutableArray alloc] initWithCapacity:2];
        for (int i = 0; i < 2; i ++) {
            NSString *imageName;
            NSString *title;
            switch (i) {
                case 0:
                {
                    imageName = @"contacts_add_voip";
                    title = @"详细信息";
                    break;
                }
                case 1: {
                    imageName = @"meeting_sign";
                    title = @"签到";
                    break;
                    
                }
                default:
                    break;
            }
            XHPopMenuItem *popMenuItem = [[XHPopMenuItem alloc] initWithImage:[UIImage imageNamed:imageName] title:title];
            [popMenuItems addObject:popMenuItem];
        }
        
        WEAKSELF
        _popMenu = [[XHPopMenu alloc] initWithMenus:popMenuItems];
        _popMenu.popMenuDidSlectedCompled = ^(NSInteger index, XHPopMenuItem *popMenuItems) {
            if (index == 0) {
                [weakSelf meeting_info];
            }else if (index == 1 ) {
                [weakSelf meeting_signin];
            }
        };
    }
    return _popMenu;
}

- (XHPopMenu *)popMenu_task {
    if (!_popMenu) {
        NSMutableArray *popMenuItems = [[NSMutableArray alloc] initWithCapacity:2];
        for (int i = 0; i < 2; i ++) {
            NSString *imageName;
            NSString *title;
            switch (i) {
                case 0:
                {
                    imageName = @"contacts_add_voip";
                    title = @"详细信息";
                    break;
                }
                case 1: {
                    imageName = @"meeting_sign";
                    title = @"转发";
                    break;
                    
                }
                default:
                    break;
            }
            XHPopMenuItem *popMenuItem = [[XHPopMenuItem alloc] initWithImage:[UIImage imageNamed:imageName] title:title];
            [popMenuItems addObject:popMenuItem];
        }
        
        WEAKSELF
        _popMenu = [[XHPopMenu alloc] initWithMenus:popMenuItems];
        _popMenu.popMenuDidSlectedCompled = ^(NSInteger index, XHPopMenuItem *popMenuItems) {
            if (index == 0) {
                [weakSelf meeting_info];
            }else if (index == 1 ) {
                [weakSelf meeting_signin];
            }
        };
    }
    return _popMenu;
}


- (void)loadTopicMessage:(NSString *) topicid page:(int) page
{
    
    NSLog(@"want to load page : %d", page);
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    
    NSString *cpage = [NSString stringWithFormat: @"%d", page];
    NSString *order = @"-1";
    
    NSString *strURL = [@"" stringByAppendingFormat:@"%@%@%@%@%@%@%@%@%@", delegate._http,delegate._server, @"/chatsfromtopic?topicid=",self._topic_id_cur,@"&page=",cpage,@"&order=",order,@"&perpage=10"];
    NSURL *url = [NSURL URLWithString:strURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setUseCookiePersistence : YES];
    [request addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    [request setValidatesSecureCertificate:NO];
    
    request.delegate = self;
    request.didFinishSelector = @selector(load_messages_finished:);
    request.didFailSelector = @selector(load_messages_failed:);
    [request startAsynchronous];
    
}

- (void)load_messages_finished:(ASIHTTPRequest *)request
{
    NSString *topics_str = [request responseString];
    NSLog(@"topics_str : %@", topics_str);
    
    [self parse_json_messages:topics_str];
}

- (void)parse_json_messages:(NSString *) topics_str
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *json = [parser objectWithString:topics_str];
    
    if (!json)
    {
        NSLog(@"cleaned...");
        [self.view makeToast:@"加载数据格式错误，请检查网络及手机是否工作正常。"];
    }
    else
    {
        NSMutableArray *cmessages = [[NSMutableArray alloc] init];
        
        
        int s_pages = [(NSString*)[json objectForKey:@"pages"] intValue];
        int s_page = [(NSString*)[json objectForKey:@"page"] intValue];
        
        
        NSArray *items = [json objectForKey:@"chats"];
        
        for(int i=(items.count - 1);i>=0;i--)
        {
            NSDictionary *topic = [items objectAtIndex:(i)];
            NSDictionary *sender = [topic objectForKey:@"_sender"];
            NSString *senderid = [sender objectForKey:@"_id"];
            
            NSString *cname = [sender objectForKey:@"name"];
            NSString *avatarurl = [sender objectForKey:@"avatar"];
            
            NSString *content = [topic objectForKey:@"content"];
            
            AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
            
            XHMessage *message = [self tranMessage:content fromSender:cname onDate:[NSDate date]];
            
            //            XHMessage *message = [[XHMessage alloc] initWithText:content sender:cname timestamp:[NSDate date]];
            
            // 判断消息发送者是否当前用户
            if([delegate._userid isEqualToString:senderid])
            {
                message.bubbleMessageType = XHBubbleMessageTypeSending;
            }
            else
            {
                message.bubbleMessageType = XHBubbleMessageTypeReceiving;
            }
            
            NSLog(@"%d%@%@%@%@%@%@", message.bubbleMessageType, @":", message.sender, @":", message.text, @":", senderid);
            
            
            [self.messages insertObject:message atIndex:0];
        }
        
        for(int i=0;i<self.messages.count;i++)
        {
            XHMessage *message = (XHMessage*)[self.messages objectAtIndex:i];
            
            NSLog(@"%d%@%d%@%@%@%@", i, @":", message.bubbleMessageType, @":", message.sender, @":", message.text);
        }
        
        
        self._page_cur = s_page;
        self._pages_cur = s_pages;
        
        //        NSLog(@"%@%d", @"client page:", self._page_cur);
        //        NSLog(@"%@%d", @"client pages:", self._pages_cur);
        //
        //        NSLog(@"%@%d", @"server page:", s_page);
        //        NSLog(@"%@%d", @"server pages:", s_pages);
    }
    
    [self.messageTableView reloadData];
    
    [self doneLoadingTableViewData];
}





- (void)load_messages_failed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error: %@", [error localizedFailureReason]);
    [self.view makeToast:@"加载数据失败，请检查网络及手机是否工作正常。"];
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[XHAudioPlayerHelper shareInstance] stopAudio];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    [self init_plusin];
    
    [self init_emotion];
    
    [self init_menu];
    
    // 蒲剑 记录当前界面记录标志，表明用户当前在聊天界面操作
    delegate._viewid = @"ChatMessage";
    delegate._viewcontroller = self;
    
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view1 = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 10.0f - self.messageTableView.bounds.size.height, self.messageTableView.frame.size.width, self.view.bounds.size.height)];
        view1.delegate = self;
        [self.messageTableView addSubview:view1];
        _refreshHeaderView = view1;
        
    }
    
    [_refreshHeaderView refreshLastUpdatedDate];
    
    [self loadTopicMessage:self._topic_id_cur page:self._page_cur + 1];
    
}

// 初始化标题菜单栏（根据不同话题类型呈现菜单）
- (void)init_menu
{
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showMenuOnView:)];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(show_menu_topic)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(show_menu_set)];
    
    self.navigationItem.rightBarButtonItems = @[item1, item2];
    
    
}



// 初始化第三方插件
- (void)init_plusin
{
    
    // 添加第三方接入数据
    NSMutableArray *shareMenuItems = [NSMutableArray array];
    NSArray *plugIcons = @[@"sharemore_pic", @"sharemore_video", @"sharemore_location", @"avator"];
    NSArray *plugTitle = @[@"照片", @"拍摄", @"位置", @"名片"];
    for (NSString *plugIcon in plugIcons) {
        XHShareMenuItem *shareMenuItem = [[XHShareMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:plugIcon] title:[plugTitle objectAtIndex:[plugIcons indexOfObject:plugIcon]]];
        [shareMenuItems addObject:shareMenuItem];
    }
    self.shareMenuItems = shareMenuItems;
    [self.shareMenuView reloadData];
    
}

// 初始化表情插件
- (void)init_emotion
{
    // 初始化表情数据 蒲剑
    NSString *path = [[NSBundle mainBundle] pathForResource:@"face" ofType:@"plist"];
    
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    _faceArray = [[NSMutableArray alloc] init];
    
    _faceArray = [tempDictionary objectForKey:@"faces"];
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegate._faceArray = _faceArray;
    
    
    // 目前仅提供1套表情 蒲剑
    NSMutableArray *emotionManagers = [NSMutableArray array];
    
    for (NSInteger i = 0; i < 1; i ++)
    {
        XHEmotionManager *emotionManager = [[XHEmotionManager alloc] init];
        emotionManager.emotionName = [NSString stringWithFormat:@"表情%ld", (long)i];
        NSMutableArray *emotions = [NSMutableArray array];
        for (NSInteger j = 0; j < 100; j ++)
        {
            
            NSString *pf = @"";
            if(j<10)
            {
                pf = @"00";
            }
            if(j>=10&&j<100)
            {
                pf = @"0";
            }
            
            XHEmotion *emotion = [[XHEmotion alloc] init];
            NSString *imageName = [NSString stringWithFormat:@"f%@%ld.gif", pf, (long)j % 99];
            
            emotion.emotionPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"f%@%ld.gif", pf, (long)j] ofType:@""];
            emotion.emotionConverPhoto = [UIImage imageNamed:imageName];
            emotion.emotionIndex = [NSNumber numberWithInt:j];
            
            [emotions addObject:emotion];
        }
        emotionManager.emotions = emotions;
        
        [emotionManagers addObject:emotionManager];
    }
    
    self.emotionManagers = emotionManagers;
    [self.emotionManagerView reloadData];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    isflage=!isflage;
    [super.navigationController setNavigationBarHidden:isflage animated:TRUE];
    [super.navigationController setToolbarHidden:isflage animated:TRUE];
}

#pragma mark - EGORefreshTableHeaderDelegate

- (void)reloadTableViewDataSource{
    NSLog(@"==开始加载数据");
    _reloading = YES;
}

- (void)doneLoadingTableViewData{
    NSLog(@"===加载完数据");
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.messageTableView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
    
    // 请求后台数据
    
    // 如果当前页数小于数据总页数，可以继续加载数据，否则，不请求。
    NSLog(@"%@%d", @"current page:", self._page_cur);
    NSLog(@"%@%d", @"current pages:", self._pages_cur);
    
    
    // if(self._page_cur<self._pages_cur)
    {
        [self loadTopicMessage:self._topic_id_cur page:self._page_cur + 1];
    }
    
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading;
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];
}



////////////////////



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.emotionManagers = nil;
    [[XHAudioPlayerHelper shareInstance] setDelegate:nil];
}

/*
 [self removeMessageAtIndexPath:indexPath];
 [self insertOldMessages:self.messages];
 */

#pragma mark - XHMessageTableViewCell delegate

- (void)multiMediaMessageDidSelectedOnMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(XHMessageTableViewCell *)messageTableViewCell {
    UIViewController *disPlayViewController;
    switch (message.messageMediaType) {
        case XHBubbleMessageMediaTypeVideo:
        case XHBubbleMessageMediaTypePhoto:
        {
            
            NSDictionary *dic = [MessageTools check_message_type:message.text];
            NSString *ctype = [dic objectForKey:@"mediatype"];
            if([ctype isEqualToString:@"file"])
            {
                [self openDocumentIn:message];
                break;
            }
            
            DLog(@"message : %@", message.photo);
            DLog(@"message : %@", message.videoConverPhoto);
            XHDisplayMediaViewController *messageDisplayTextView = [[XHDisplayMediaViewController alloc] init];
            messageDisplayTextView.message = message;
            disPlayViewController = messageDisplayTextView;
            break;
        }
            break;
        case XHBubbleMessageMediaTypeVoice: {
            DLog(@"message path: %@", message.voicePath);
            DLog(@"message url: %@", message.voiceUrl);
            [[XHAudioPlayerHelper shareInstance] setDelegate:self];
            if (_currentSelectedCell)
            {
                [_currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
            }
            if (_currentSelectedCell == messageTableViewCell)
            {
                [messageTableViewCell.messageBubbleView.animationVoiceImageView stopAnimating];
                [[XHAudioPlayerHelper shareInstance] stopAudio];
                self.currentSelectedCell = nil;
            }
            else
            {
                self.currentSelectedCell = messageTableViewCell;
                [messageTableViewCell.messageBubbleView.animationVoiceImageView startAnimating];
                [[XHAudioPlayerHelper shareInstance] managerAudioWithFileName:message.voiceUrl toPlay:YES];
            }
            break;
        }
        case XHBubbleMessageMediaTypeEmotion:
            DLog(@"facePath : %@", message.emotionPath);
            break;
        case XHBubbleMessageMediaTypeLocalPosition: {
            DLog(@"facePath : %@", message.localPositionPhoto);
            XHDisplayLocationViewController *displayLocationViewController = [[XHDisplayLocationViewController alloc] init];
            displayLocationViewController.message = message;
            disPlayViewController = displayLocationViewController;
            break;
        }
        default:
            break;
    }
    if (disPlayViewController) {
        [self.navigationController pushViewController:disPlayViewController animated:YES];
    }
}

-(void)openDocumentIn:(id<XHMessageModel>)message
{
    @try
    {
        
        
        NSURL *url = [NSURL URLWithString:message.originPhotoUrl];
        
        
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
        [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *resp, NSData *respData, NSError *error){
            NSLog(@"resp data length: %i", respData.length);
            NSString *fileName = @"temp.txt";
            NSString * path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
            NSError *errorC = nil;
            BOOL success = [respData writeToFile:path
                                         options:NSDataWritingFileProtectionComplete
                                           error:&errorC];
            
            if (success) {
                documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
                documentController.delegate = self;
                [documentController presentOptionsMenuFromRect:CGRectZero inView:self.view animated:YES];
            } else {
                NSLog(@"fail: %@", errorC.description);
            }
        }];
        
        
        
        
        
        
        
        
        
    }
    @catch(NSException *e)
    {
        NSLog(@"%@", e.reason);
    }
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
       willBeginSendingToApplication:(NSString *)application {
    
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
          didEndSendingToApplication:(NSString *)application {
    
}

-(void)documentInteractionControllerDidDismissOpenInMenu:
(UIDocumentInteractionController *)controller {
    
}

- (void)didDoubleSelectedOnTextMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
    DLog(@"text : %@", message.text);
    XHDisplayTextViewController *displayTextViewController = [[XHDisplayTextViewController alloc] init];
    displayTextViewController.message = message;
    [self.navigationController pushViewController:displayTextViewController animated:YES];
}

- (void)didSelectedAvatorOnMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
    DLog(@"indexPath : %@", indexPath);
    XHContact *contact = [[XHContact alloc] init];
    contact.contactName = [message sender];
    contact.contactIntroduction = @"自定义描述，这个需要和业务逻辑挂钩";
    XHContactDetailTableViewController *contactDetailTableViewController = [[XHContactDetailTableViewController alloc] initWithContact:contact];
    [self.navigationController pushViewController:contactDetailTableViewController animated:YES];
}

- (void)menuDidSelectedAtBubbleMessageMenuSelecteType:(XHBubbleMessageMenuSelecteType)bubbleMessageMenuSelecteType {
    
}

#pragma mark - XHAudioPlayerHelper Delegate

- (void)didAudioPlayerStopPlay:(AVAudioPlayer *)audioPlayer {
    if (!_currentSelectedCell) {
        return;
    }
    [_currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
    self.currentSelectedCell = nil;
}

#pragma mark - XHEmotionManagerView DataSource

- (NSInteger)numberOfEmotionManagers {
    return self.emotionManagers.count;
}

- (XHEmotionManager *)emotionManagerForColumn:(NSInteger)column {
    return [self.emotionManagers objectAtIndex:column];
}

- (NSArray *)emotionManagersAtManager {
    return self.emotionManagers;
}

#pragma mark - XHMessageTableViewController Delegate

- (BOOL)shouldLoadMoreMessagesScrollToTop {
    return YES;
}

/**
 *  发送文本消息的回调方法
 *
 *  @param text   目标文本字符串
 *  @param sender 发送者的名字
 *  @param date   发送时间
 */
- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    
    XHMessage *textMessage = [[XHMessage alloc] initWithText:text sender:sender timestamp:date];
    [self addMessage:textMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];
    
    // 蒲剑 添加
    // 发送消息服务器
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSString *content = text;
    NSString *topicid = self._topic_id_cur;
    NSString *msender = delegate._userid;
    NSString *msendercname = delegate._username;
    [self send_message_text:content topicid:topicid sender:msender sendername:msendercname];
}


/**
 *  发送图文混排文本消息的回调方法
 *
 *  @param text   目标文本字符串
 *  @param sender 发送者的名字
 *  @param date   发送时间
 */
- (void)didSendRichText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date
{
    XHMessage *message = [self tranMessage:text fromSender:sender onDate:date];
    [self addMessage:message];
    [self finishSendMessageWithBubbleMessageType:message.messageMediaType];
    
    // 蒲剑 添加
    // 发送消息服务器
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSString *content = text;
    NSString *topicid = self._topic_id_cur;
    NSString *msender = delegate._userid;
    NSString *msendercname = delegate._username;
    [self send_message_text:content topicid:topicid sender:msender sendername:msendercname];
}


-(XHMessage *)tranMessage:(NSString *) text fromSender:(NSString *)sender onDate:(NSDate *)date
{
    
    NSMutableDictionary *dictionary;
    dictionary = [MessageTools check_message_type:text];
    NSString *mediatype = [dictionary objectForKey:@"mediatype"];
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    XHMessage *message;
    
    if([@"face" isEqualToString:mediatype])
    {
        message = [[XHMessage alloc] initWithText:text sender:sender timestamp:date];
        return message;
    }
    
    if([@"record" isEqualToString:mediatype])
    {
        NSString *fileid = (NSString*)[dictionary objectForKey:@"fileid"];
        NSString *url = [@"" stringByAppendingFormat:@"%@%@%@%@", delegate._http,delegate._server, @"/download/", fileid];
        
        message = [[XHMessage alloc] initWithVoicePath:url voiceUrl:url voiceDuration:0 sender:sender timestamp:date];
        message.text = text;
        return message;
    }
    
    if([@"image" isEqualToString:mediatype])
    {
        NSString *fileid = (NSString*)[dictionary objectForKey:@"fileid"];
        NSString *url = [@"" stringByAppendingFormat:@"%@%@%@%@", delegate._http,delegate._server, @"/download/", fileid];
        
        UIImage *pic = [UIImage imageNamed:@"app_panel_pic_icon.9.png"];
        message = [[XHMessage alloc] initWithPhoto:pic thumbnailUrl:nil originPhotoUrl:url sender:sender timestamp:date];
        message.text = text;
        return message;
    }
    
    if([@"file" isEqualToString:mediatype])
    {
        NSString *fileid = (NSString*)[dictionary objectForKey:@"fileid"];
        NSString *url = [@"" stringByAppendingFormat:@"%@%@%@%@", delegate._http,delegate._server, @"/download/", fileid];
        
        UIImage *pic = [UIImage imageNamed:@"ofm_mail_icon.png"];
        //        message = [[XHMessage alloc] initWithFile:pic filePath:nil fileUrl:url sender:sender timestamp:date];
        message = [[XHMessage alloc] initWithPhoto:pic thumbnailUrl:nil originPhotoUrl:url sender:sender timestamp:date];
        
        message.text = text;
        return message;
    }
    
    
    message = [[XHMessage alloc] initWithText:text sender:sender timestamp:date];
    
    return message;
    
}


/**
 *  发送图片消息的回调方法
 *
 *  @param photo  目标图片对象，后续有可能会换
 *  @param sender 发送者的名字
 *  @param date   发送时间
 */
- (void)didSendPhoto:(UIImage *)photo fromSender:(NSString *)sender onDate:(NSDate *)date {
    
    CGSize gsize = CGSizeMake(128, 128);
    UIImage *gphoto = [ImageTools compress_image:photo scaledToSize:gsize]; // 压缩图像
    
    NSString *photoPath = [ImageTools save_image:photo WithName:@"temp.jpg"]; //上传原图
    
    _upload_image_temp = gphoto;
    _upload_imagefilename_temp = [photoPath lastPathComponent];
    
    [self upload_photo:photoPath];
}

/**
 *  发送视频消息的回调方法
 *
 *  @param videoPath 目标视频本地路径
 *  @param sender    发送者的名字
 *  @param date      发送时间
 */
- (void)didSendVideoConverPhoto:(UIImage *)videoConverPhoto videoPath:(NSString *)videoPath fromSender:(NSString *)sender onDate:(NSDate *)date {
    XHMessage *videoMessage = [[XHMessage alloc] initWithVideoConverPhoto:videoConverPhoto videoPath:videoPath videoUrl:nil sender:sender timestamp:date];
    videoMessage.avator = [UIImage imageNamed:@"avator"];
    videoMessage.avatorUrl = @"http://tp2.sinaimg.cn/1966395317/180/5606145763/1";
    [self addMessage:videoMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeVideo];
}

/**
 *  发送语音消息的回调方法
 *
 *  @param voicePath        目标语音本地路径
 *  @param voiceDuration    目标语音时长
 *  @param sender           发送者的名字
 *  @param date             发送时间
 */
- (void)didSendVoice:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration fromSender:(NSString *)sender onDate:(NSDate *)date
{
    [self upload_voice:voicePath];
    
}

/**
 *  发送第三方表情消息的回调方法
 *
 *  @param facePath 目标第三方表情的本地路径
 *  @param sender   发送者的名字
 *  @param date     发送时间
 */
- (void)didSendEmotion:(NSString *)emotionPath fromSender:(NSString *)sender onDate:(NSDate *)date {
    //    XHMessage *emotionMessage = [[XHMessage alloc] initWithEmotionPath:emotionPath sender:sender timestamp:date];
    //    emotionMessage.avator = [UIImage imageNamed:@"avator"];
    //    emotionMessage.avatorUrl = @"http://tp2.sinaimg.cn/1966395317/180/5606145763/1";
    //    [self addMessage:emotionMessage];
    //    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeEmotion];
    NSString *text = @"[[face:大笑]]";
    
    NSString *oldtext = self.messageInputView.inputTextView.text;
    
    self.messageInputView.inputTextView.text = [oldtext stringByAppendingFormat:@"%@", text];
    
    // [self didSendText:text fromSender:sender onDate:date];
}

// 蒲剑测试
- (void)didSendEmotionN:(XHEmotion *)emotion fromSender:(NSString *)sender onDate:(NSDate *)date {
    //    XHMessage *emotionMessage = [[XHMessage alloc] initWithEmotionPath:emotionPath sender:sender timestamp:date];
    //    emotionMessage.avator = [UIImage imageNamed:@"avator"];
    //    emotionMessage.avatorUrl = @"http://tp2.sinaimg.cn/1966395317/180/5606145763/1";
    //    [self addMessage:emotionMessage];
    //    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeEmotion];
    // NSString *text = @"[[face:大笑]]";
    
    int index = [emotion.emotionIndex intValue];
    
    NSDictionary *emotion_obj = _faceArray[index];
    NSString *text = [@"" stringByAppendingFormat:@"%@%@%@", @"[[face:", [emotion_obj objectForKey:@"cname" ], @"]]"];
    
    NSString *oldtext = self.messageInputView.inputTextView.text;
    
    self.messageInputView.inputTextView.text = [oldtext stringByAppendingFormat:@"%@", text];
    
    // [self didSendText:text fromSender:sender onDate:date];
}



/**
 *  有些网友说需要发送地理位置，这个我暂时放一放
 */
- (void)didSendGeoLocationsPhoto:(UIImage *)geoLocationsPhoto geolocations:(NSString *)geolocations location:(CLLocation *)location fromSender:(NSString *)sender onDate:(NSDate *)date {
    XHMessage *geoLocationsMessage = [[XHMessage alloc] initWithLocalPositionPhoto:geoLocationsPhoto geolocations:geolocations location:location sender:sender timestamp:date];
    geoLocationsMessage.avator = [UIImage imageNamed:@"avator"];
    geoLocationsMessage.avatorUrl = @"http://tp2.sinaimg.cn/1966395317/180/5606145763/1";
    [self addMessage:geoLocationsMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeLocalPosition];
}

/**
 *  是否显示时间轴Label的回调方法
 *
 *  @param indexPath 目标消息的位置IndexPath
 *
 *  @return 根据indexPath获取消息的Model的对象，从而判断返回YES or NO来控制是否显示时间轴Label
 */
- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

/**
 *  配置Cell的样式或者字体
 *
 *  @param cell      目标Cell
 *  @param indexPath 目标Cell所在位置IndexPath
 */
- (void)configureCell:(XHMessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
}

/**
 *  协议回掉是否支持用户手动滚动
 *
 *  @return 返回YES or NO
 */
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling {
    return YES;
}


-(void) send_message_text: (NSString *)content topicid:(NSString *)topicid sender:(NSString *)sender sendername:(NSString *)sendercname
{
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSString *strURL = [@"" stringByAppendingFormat:@"%@%@%@", delegate._http,delegate._server, @"/chats"];
    NSURL *url = [NSURL URLWithString:strURL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setUseCookiePersistence : YES];
    [request addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    [request setRequestMethod:@"POST"];
    
    [request setPostValue:content forKey:@"content"];
    [request setPostValue:topicid forKey:@"_maindoc"];
    
    request.delegate = self;
    request.didFinishSelector = @selector(send_message_finished:);
    request.didFailSelector = @selector(send_message_failed:);
    [request startAsynchronous];
}

- (void)send_message_finished:(ASIHTTPRequest *)request
{
    NSString *topics_str = [request responseString];
    NSLog(@"topics_str : %@", topics_str);
}

- (void)send_message_failed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error: %@", [error localizedFailureReason]);
    [self.view makeToast:@"消息发送异常，可能网络异常，请稍后再试。"];
}

-(void) upload_voice: (NSString *)voicepath
{
    
    NSString *newvoicepath = voicepath;
    
    // [VoiceTools pcm_to_mp3:voicepath];
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSString *strURL = [@"" stringByAppendingFormat:@"%@%@%@", delegate._http,delegate._server, @"/upload"];
    NSURL *url = [NSURL URLWithString:strURL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setUseCookiePersistence : YES];
    [request addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    [request setRequestMethod:@"POST"];
    
    NSString *fileName = [newvoicepath lastPathComponent];
    
    [request setPostValue:fileName forKey:@"originalFilename"];
    [request setFile:(newvoicepath) forKey:@"upfile"];
    
    request.delegate = self;
    request.didFinishSelector = @selector(upload_voice_finished:);
    request.didFailSelector = @selector(upload_voice_failed:);
    [request startAsynchronous];
}


- (void)upload_voice_finished:(ASIHTTPRequest *)request
{
    NSString *voice_str = [request responseString];
    NSLog(@"voice_str : %@", voice_str);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *json = [parser objectWithString:voice_str];
    
    if (!json)
    {
        NSLog(@"cleaned...");
        [self.view makeToast:@"发送失败，请稍后再试。"];
        return;
    }
    
    NSString *fileid = [json objectForKey:@"id"];
    NSString *type = @"record";
    NSString *content = [@"" stringByAppendingFormat:@"%@%@%@%@%@", @"[[", type, @":", fileid, @"]]"];
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSString *msendercname = delegate._username;
    
    [self didSendRichText:content fromSender:msendercname onDate:[NSDate date]];
    
}

- (void)upload_voice_failed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error: %@", [error localizedFailureReason]);
    [self.view makeToast:@"消息发送异常，可能网络异常，请稍后再试。"];
}


-(void) upload_photo: (NSString *)voicepath
{
    
    NSString *newvoicepath = voicepath;
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSString *strURL = [@"" stringByAppendingFormat:@"%@%@%@", delegate._http,delegate._server, @"/upload"];
    NSURL *url = [NSURL URLWithString:strURL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence : YES];
    [request addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    
    [request setRequestMethod:@"POST"];
    
    NSString *fileName = [newvoicepath lastPathComponent];
    
    [request setPostValue:fileName forKey:@"originalFilename"];
    [request setFile:(newvoicepath) forKey:@"upfile"];
    
    request.delegate = self;
    request.didFinishSelector = @selector(upload_photo_finished:);
    request.didFailSelector = @selector(upload_photo_failed:);
    [request startAsynchronous];
}

- (void)upload_photo_finished:(ASIHTTPRequest *)request
{
    NSString *voice_str = [request responseString];
    NSLog(@"voice_str : %@", voice_str);
    
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *json = [parser objectWithString:voice_str];
    
    if (!json)
    {
        NSLog(@"cleaned...");
        [self.view makeToast:@"发送失败，请稍后再试。"];
        return;
    }
    
    NSString *fileid = [json objectForKey:@"id"];
    NSString *type = @"image";
    NSString *content = [@"" stringByAppendingFormat:@"%@%@%@%@%@%@%@", @"[[", type, @":", fileid, @"?", _upload_imagefilename_temp, @"]]"];
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSString *msendercname = delegate._username;
    
    [self didSendRichText:content fromSender:msendercname onDate:[NSDate date]];
    
}

- (void)upload_photo_failed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error: %@", [error localizedFailureReason]);
    [self.view makeToast:@"消息发送异常，可能网络异常，请稍后再试。"];
}



- (void)meeting_info
{
    
}

- (void)meeting_signin
{
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSString *strURL = [@"" stringByAppendingFormat:@"%@%@%@%@%@", delegate._http,delegate._server, @"/meetings/",self._topic_id_cur,@"/signin/1"];
    NSURL *url = [NSURL URLWithString:strURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setUseCookiePersistence : YES];
    [request addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    [request setRequestMethod:@"POST"];
    
    request.delegate = self;
    request.didFinishSelector = @selector(meeting_signin_finished:);
    request.didFailSelector = @selector(meeting_signin_failed:);
    [request startAsynchronous];
    
}

- (void)meeting_signin_finished:(ASIHTTPRequest *)request
{
    NSString *signin_str = [request responseString];
    NSLog(@"signin_str : %@", signin_str);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *json = [parser objectWithString:signin_str];
    
    if (!json)
    {
        NSLog(@"cleaned...");
        [self.view makeToast:@"签到失败，请稍后再试。"];
        return;
    }
    else
    {
        [self.view makeToast:@"签到成功。"];
    }
}

- (void)meeting_signin_failed:(ASIHTTPRequest *)request
{
    [self.view makeToast:@"签到失败，请检查网络及手机是否工作正常。"];
}


@end
