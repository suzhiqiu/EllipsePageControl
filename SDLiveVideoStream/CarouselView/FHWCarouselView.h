//
//  FHWCarouselView.h

//

#import <UIKit/UIKit.h>
#import "FHWPageControl.h"

typedef NS_ENUM(NSUInteger, FHWCarouselPageControlAt) {
    FHWCarouselPageControlAtCenter,
    FHWCarouselPageControlAtLeft,
    FHWCarouselPageControlAtRight,
};

typedef NS_ENUM(NSUInteger, FHWCarouselPageControlStyle) {
    FHWCarouselPageControlStyleEllipRect,    /**<  椭圆形  */
    FHWCarouselPageControlStyleDot,          /**<  点  */
};

@interface FHWCarouselView : UIView

@property (nonatomic,   copy) NSArray *models;                                  /**<  数据源  */
@property (nonatomic, assign) NSInteger currentIndex;                           /**<  当前位置  */
@property (nonatomic, assign) BOOL isNotLoopPlay;                               /**<  是否循环播放  */
@property (nonatomic, assign) BOOL isNotAutoPlay;                               /**<  是否自动播放  */
@property (nonatomic, assign) NSTimeInterval animationDuration;                 /**<  动画时间,请勿设置 < 1s  */
@property (nonatomic, assign) FHWCarouselPageControlAt pageControlPosition;     /**<  pageControl位置  */
@property (nonatomic, assign) FHWCarouselPageControlStyle pageControlStyle;     /**<  pageControl样式  */
@property (nonatomic, assign) NSInteger dotOffsetFoot;                          /**<  点距离底部的距离  */
@property (nonatomic, copy)   NSString *defaultImage;                           /**<  默认图  */
@property (nonatomic, assign) UIViewContentMode  contentMode;                   /**<  contentMode  */
@property (nonatomic, strong) FHWPageControl *fhwPageControl;

@property (nonatomic,   copy) void (^onDidClickEvent)(NSInteger index);         /**<  点击事件 */
@property (nonatomic,   copy) void (^onDidScrollToIndex)(NSInteger index);      /**<  滚动事件 */

- (void)loadData;
- (void)startAnimating;
- (void)stopAnimating;

@end
