//
//  IMYViewController.m
//  SDLiveVideoStream
//
//  Created by suzq on 2019/3/5.
//  Copyright © 2019 suzq. All rights reserved.
//

#import "IMYViewController.h"
#import "FHWCarouselView.h"

@interface IMYViewController ()

/*轮播banne*/
@property (nonatomic, strong) FHWCarouselView *carouselView;

@end

@implementation IMYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.carouselView];
    
    //可以替换线上清晰图片
    NSArray *urls=@[@"https://img.alicdn.com/imgextra/i2/880734502/O1CN01lZIjRa1j7xbQGio11_!!0-item_pic.jpg_60x60q90.jpg",
                    @"https://img.alicdn.com/imgextra/i2/880734502/O1CN01ft1XiQ1j7xasCjtnZ-880734502.jpg_60x60q90.jpg",
                    @"https://img.alicdn.com/imgextra/i1/880734502/O1CN01dRZ3jT1j7xZ6j5y02_!!0-item_pic.jpg_60x60q90.jpg",
                    @"https://img.alicdn.com/imgextra/i4/880734502/TB2wAJ1gFXXXXcUXpXXXXXXXXXX_!!880734502.jpg_60x60q90.jpg",
                    @"https://img.alicdn.com/imgextra/i1/880734502/O1CN01kacPqB1j7xatbps7U-880734502.jpg_60x60q90.jpg"];
    
    self.carouselView.models=urls;
}

-(void)dealloc
{
    [self.carouselView stopAnimating];
}
/*轮播视图*/
-(FHWCarouselView *)carouselView
{
   
    
    if (!_carouselView){
        _carouselView =({
            FHWCarouselView *v = [[FHWCarouselView alloc] initWithFrame:CGRectMake(0, 64 ,SCREEN_WIDTH, SCREEN_WIDTH)];
            v.pageControlStyle = FHWCarouselPageControlStyleEllipRect;
            v.dotOffsetFoot = 5;
            v.backgroundColor = [UIColor clearColor];
            v.isNotAutoPlay = YES;//去掉轮播
            v.isNotLoopPlay = YES;
            v.hidden = NO;
            v.defaultImage=@"default_screenwidth";
            v.fhwPageControl.controlColor= UIColorFromRGB(0xe8e8e8);
            v.fhwPageControl.controlSelectedColor= UIColorFromRGB(0xf4464f);
            v.fhwPageControl.controlSpacing=10;
            v.fhwPageControl.controlSize=6;
            v.fhwPageControl.controlSelectedSize=12;
            v.contentMode=UIViewContentModeScaleAspectFill;
            v;
        });
    }
    return _carouselView;
}

@end
