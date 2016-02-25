//
//  PullDownTextField.m
//  textfield
//
//  Created by 李洋 on 15/12/2.
//  Copyright © 2015年 shunweige. All rights reserved.
//

#import "PullDownView.h"
//弱引用
#define WEAKSELF typeof(self) __weak weakSelf = self;

#define withAndHeight 20
#define DOWNPULLBTNHEIGHTANDWEITH 50

@implementation PullDownView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
        
    }
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self createUI];
        
    }
    return self;
}

-(void)createUI{
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _isOpen = NO;
    self.title = [[UILabel alloc]init];
    self.title.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.title];
    
    //downPullBtn
    self.downPullBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.downPullBtn addTarget:self action:@selector(didClickDownPullBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.downPullBtn setImage:[UIImage imageNamed:@"bluePull"] forState:UIControlStateNormal];
    [self addSubview:self.downPullBtn];
    
    //点击viewBtn
    self.viewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.viewBtn addTarget:self action:@selector(didClickDownPullBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.viewBtn.backgroundColor = [UIColor clearColor];
    [self addSubview:self.viewBtn];
    
    self.listTable = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _listTable.bounces = NO;
    _listTable.delegate = self;
    _listTable.dataSource = self;
    _listTable.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [_superView addSubview:_listTable];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.title.frame = CGRectMake(0, 1, self.frame.size.width, self.frame.size.height-1);
    self.downPullBtn.frame = CGRectMake(self.frame.size.width-self.frame.size.height, -1, DOWNPULLBTNHEIGHTANDWEITH, DOWNPULLBTNHEIGHTANDWEITH);
    self.downPullBtn.imageEdgeInsets = UIEdgeInsetsMake(18, 13, 18, 13);
    self.viewBtn.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.listTable.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y + self.frame.size.height, self.frame.size.width, 100);
}


-(void)didClickDownPullBtn:(UIButton*)btn{
    [self tapAction];
}

#pragma mark -tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.frame.size.height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cellIndentifier";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *label;
    if(cell==nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        cell.backgroundColor =[UIColor groupTableViewBackgroundColor];
        label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width-4, self.frame.size.height)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        label.tag = 1000;
        [cell addSubview:label];
    }
    label.text = self.listArray[indexPath.row];
    return cell;
}

//关闭tableView
-(void)closeTableView{
    WEAKSELF
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _listTable.frame;
        frame.size.height = 0;
        [weakSelf.listTable setFrame:frame];
    } completion:^(BOOL finished){
        [weakSelf.listTable removeFromSuperview];//移除
        weakSelf.isOpen = NO;
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.title.text = [_listArray objectAtIndex:indexPath.row];
    _isOpen = YES;
    [self tapAction];
    if([_delegate respondsToSelector:@selector(selectAtIndex:inCombox:)])
    {
        [_delegate selectAtIndex:indexPath.row inCombox:self];
    }
    [self performSelector:@selector(deSelectedRow) withObject:nil afterDelay:0.2];
}

-(void)tapAction{
    if(_isOpen)
    {
        [self closeTableView];
    }
    else
    {
        WEAKSELF
        [UIView animateWithDuration:0.3 animations:^{
            if(weakSelf.listArray.count > 0)
            {
                /*
                 注意：如果不加这句话，下面的操作会导致_listTable从上面飘下来的感觉：
                 _listTable展开并且滑动到底部 -> 点击收起 -> 再点击展开
                 */
                [weakSelf.listTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
            CGRect frame = _listTable.frame;
            frame.size.height = self.listArray.count *weakSelf.frame.size.height;
            NSInteger canSeeNumber = self.canSeeCount?self.canSeeCount:3;
            if (self.listArray.count >= canSeeNumber) {
            frame.size.height = weakSelf.frame.size.height * canSeeNumber;
                }
            [weakSelf.listTable setFrame:frame];
            [weakSelf.superView addSubview:_listTable];
            [weakSelf.superView bringSubviewToFront:_listTable];//避免被其他子视图遮盖住

        } completion:^(BOOL finished){
            weakSelf.isOpen = YES;
        }];
    }
}

-(void)deSelectedRow
{
    [_listTable deselectRowAtIndexPath:[_listTable indexPathForSelectedRow] animated:YES];
}

#pragma mark ----ios8 ios7 分割线到头
-(void)viewDidLayoutSubviews
{
    if ([self.listTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.listTable setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.listTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.listTable setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}



@end
