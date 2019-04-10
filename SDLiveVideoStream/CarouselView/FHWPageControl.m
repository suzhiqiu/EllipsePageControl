//
//  FHWPageControl
//
//  Created by suzq on 2017/7/26.
//

#import "FHWPageControl.h"

///RGB 色值
#define COLOR_RGB(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define COLOR_RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]


@implementation FHWPageControl



- (instancetype)init
{
    self = [super init];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    [self initView];
//}

#pragma mark - init

- (void)baseInit
{
    self.numberOfPages = 0;
    self.currentPage = 0;
    self.controlSpacing = 5.f;
    self.controlSize = 4.f;
    self.controlSelectedSize = 14.f;
    self.animationTime = 0.25f;
    self.controlColor = COLOR_RGBA(255, 255, 255, 0.65);
    self.controlSelectedColor = [UIColor whiteColor];
    self.bCanClick=NO;
}

static NSInteger pageControlTag = 555;

- (void)initView
{
    if (self.numberOfPages < 2) {
        return;
    }
    if (self.frame.size.height < self.controlSize) {
        return;
    }
    [self clearAllView];
    CGFloat totalWidth = (self.controlSpacing + self.controlSize) * (self.numberOfPages - 1) + self.controlSelectedSize;
    if (self.frame.size.width < totalWidth) {
        return;
    }
    CGFloat originX = (self.frame.size.width - totalWidth) / 2;
    CGFloat originY = (self.frame.size.height - self.controlSize) / 2;
    for (int i = 0; i < self.numberOfPages; i++) {
        UIButton *control = [UIButton buttonWithType:(UIButtonTypeCustom)];
        control.tag = pageControlTag + i;
        CGFloat controlWidth = self.controlSize;
        control.backgroundColor = self.controlColor;
        if (i == self.currentPage) {
            controlWidth = self.controlSelectedSize;
            control.backgroundColor = self.controlSelectedColor;
        }
        control.frame = CGRectMake(originX, originY, controlWidth, self.controlSize);
        control.layer.cornerRadius = self.controlSize / 2;
        if(self.bCanClick)
        {
            [control addTarget:self action:@selector(controlSelected:) forControlEvents:(UIControlEventTouchUpInside)];
        }
        [self addSubview:control];
        originX += (controlWidth + self.controlSpacing);
    }
}

#pragma mark - action

- (void)controlSelected:(UIButton *)button
{
    NSUInteger index = button.tag - pageControlTag;
    self.currentPage = index;
    if (self.controlSelect) {
        self.controlSelect(self, index);
    }
}

- (void)changeSelectdWithIndex:(NSUInteger)index
{
    NSUInteger originIndex = self.currentPage;
    UIButton *originBtn = [self viewWithTag:pageControlTag + originIndex];
    UIButton *otherBtn = [self viewWithTag:pageControlTag + index];
    
    [UIView animateWithDuration:self.animationTime animations:^{
        originBtn.backgroundColor = self.controlColor;
        otherBtn.backgroundColor = self.controlSelectedColor;
        
        for (NSUInteger i = MIN(originIndex, index); i <= MAX(originIndex, index); i++) {
            CGFloat addX = 0.f;
            if (i == MIN(originIndex, index)) {
                addX = 0.f;
            } else if (originIndex < index) {
                addX = self.controlSize - self.controlSelectedSize;
            } else {
                addX = self.controlSelectedSize - self.controlSize;
            }
            CGFloat width = self.controlSize;
            if (i == index) {
                width = self.controlSelectedSize;
            }
            UIButton *btn = [self viewWithTag:i + pageControlTag];
            CGRect frame = btn.frame;
            frame.origin.x += addX;
            frame.size.width = width;
            btn.frame = frame;
        }
    }];
}

#pragma mark - setter

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self initView];
}

- (void)setNumberOfPages:(NSUInteger)pageNumber
{
    if (_numberOfPages != pageNumber) {
        _numberOfPages=pageNumber;
        [self initView];
    }
}


- (void)setControlSize:(CGFloat)controlSize
{
    if (_controlSize!=controlSize) {
        _controlSize = controlSize;
        [self initView];
    }
}

- (void)setControlSelectedSize:(CGFloat)controlSelectedSize
{
    if (_controlSelectedSize!=controlSelectedSize) {
        _controlSelectedSize = controlSelectedSize;
        [self initView];
    }
}

- (void)setControlSpacing:(CGFloat)controlSpacing
{
    if (_controlSpacing!=controlSpacing) {
        _controlSpacing = controlSpacing;
        [self initView];
    }
}

- (void)setControlColor:(UIColor *)controlColor
{
    if (!color_equal(_controlColor, controlColor)) {
        _controlColor = controlColor;
        [self initView];
    }
}

- (void)setControlSelectedColor:(UIColor *)controlSelectedColor
{
    if (!color_equal(_controlSelectedColor, controlSelectedColor)) {
        _controlSelectedColor = controlSelectedColor;
        [self initView];
    }
}

- (void)setCurrentPage:(NSUInteger)currentPage
{
    if (_currentPage != currentPage) {
        [self changeSelectdWithIndex:currentPage];
        _currentPage = currentPage;
    }
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount
{
    CGFloat width = pageCount * (self.controlSize + self.controlSpacing) + self.controlSelectedSize;
    return CGSizeMake(width, self.bounds.size.height);
}

#pragma mark - private

- (void)clearAllView
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

bool color_equal(UIColor *origin, UIColor *other) {
    return CGColorEqualToColor(origin.CGColor, other.CGColor);
}

@end
