//
//  FHWPageControl.h
//

#import <UIKit/UIKit.h>

@interface FHWPageControl : UIView

/*页数*/
@property (nonatomic) NSUInteger numberOfPages;
/*当前页*/
@property (nonatomic) NSUInteger currentPage;
/*按钮大小*/
@property (nonatomic) CGFloat controlSize;
/*选择按钮宽度度*/
@property (nonatomic) CGFloat controlSelectedSize;
/* 空隙宽度*/
@property (nonatomic) CGFloat controlSpacing;
/* 动画时长*/
@property (nonatomic) CGFloat animationTime;
/*按钮颜色*/
@property (nonatomic, strong) UIColor *controlColor;
/*选中颜色*/
@property (nonatomic, strong) UIColor *controlSelectedColor;
/*点击按钮回调*/
@property (nonatomic, copy) void(^controlSelect)(FHWPageControl *pageControl, NSUInteger index);
/*点击点点是否进行切换 默认是NO*/
@property(nonatomic,assign) BOOL bCanClick;

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;

@end
