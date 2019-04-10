//
//  ReactiveTableViewCell.h
//  SDLiveVideoStream
//
//  Created by suzhiqiu on 2017/8/5.
//  Copyright © 2017年 suzq. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReactiveTableViewCell <NSObject>


-(instancetype)bindModel:(id)model cellForRowIndexPath:(NSIndexPath *)indexPath viewModel:(id)viewModel;

@optional
-(CGFloat)bindModel:(id)model heightForRowAtIndexPath:(NSIndexPath *)indexPath viewModel:(id)viewModel;


@end
