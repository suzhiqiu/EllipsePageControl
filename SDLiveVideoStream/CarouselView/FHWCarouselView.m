//
//  FHWCarouselView.m
//  fanhuanwang
//

#import "FHWCarouselView.h"

static NSInteger const collectionViewSectionCount = 2000;

#pragma mark - FHWCarouselCell Class
@interface FHWCarouselCell : UICollectionViewCell
@property (nonatomic, strong) FLAnimatedImageView *imageView;
@property (nonatomic, copy)   NSString *defaultImage;                           /**<  默认图  */
@property (nonatomic, assign) UIViewContentMode  contentMode;                   /**<  contentMode  */

- (void)updateWithData:(id)data;
@end

@implementation FHWCarouselCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.contentMode=UIViewContentModeScaleToFill;//默认的样式
    self.imageView = ({
        FLAnimatedImageView *view = [[FLAnimatedImageView alloc] initWithFrame:self.bounds];
        view.backgroundColor = [UIColor clearColor];
        view.contentMode = UIViewContentModeScaleToFill;
        view.clipsToBounds = YES;
        view;
    });
    
    [self.contentView addSubview:self.imageView];
    self.contentView.clipsToBounds=YES;
}

- (void)updateWithData:(id)data {
    self.imageView.contentMode=self.contentMode;
    UIImage *defaultImage=nil;
    if(!imy_isEmptyString(self.defaultImage)){
        defaultImage= [UIImage imageNamed:self.defaultImage];
    }
    if ([data isKindOfClass:[NSString class]]) {
        NSString *urlStr = data;
        [self.imageView sd_setImageFadeWithURL:[NSURL URLWithString:urlStr] placeholderImage:defaultImage options:SD_FF_OPTIONS];
    } else if ([data isKindOfClass:[NSURL class]]) {
        NSURL *url = data;
        [self.imageView sd_setImageFadeWithURL:url placeholderImage:defaultImage options:SDWebImageRetryFailed|SDWebImageLowPriority];
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = data;
        [self.imageView sd_setImageFadeWithURL:[NSURL URLWithString:dict[@"url"]] placeholderImage:defaultImage options:SD_FF_OPTIONS];
        int itemId = [dict[@"id"] intValue];
        self.imageView.tag = itemId;
    }
}

@end

#pragma mark - FHWCarouselView Class
@interface FHWCarouselView () <UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, assign) NSInteger draggingIndex;
@property (nonatomic, strong) NSTimer *animationTimer;

@end

@implementation FHWCarouselView

#pragma mark - Override
- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ceil(110 * SCREEN_RATIO))];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initSelf];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSelf];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

-(void)restart{
    [self loadData];
    [self fixStartPosition];
    [self startAnimating];
}

- (void)setModels:(NSArray *)images
{
    _models = [images copy];
    [self restart];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (newWindow) {
        [self resumeAnimating];
    } else {
        [self pauseAnimating];
    }
}

- (void)dealloc {
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    [self stopAnimating];
}

#pragma mark - InitSelf
- (void)initSelf {
    [self initData];
    [self initSubviews];
    [self setup];
}

- (void)initData {
    self.dotOffsetFoot = 11;
    self.animationDuration = 3;
}

- (void)initSubviews {
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat selfHeight = self.bounds.size.height;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.itemSize = self.bounds.size;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsZero;
    
    self.collectionView = ({
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        [collectionView registerClass:[FHWCarouselCell class] forCellWithReuseIdentifier:NSStringFromClass([FHWCarouselCell class])];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.pagingEnabled = YES;
        collectionView.scrollsToTop = NO;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        collectionView.backgroundColor = [UIColor clearColor];
        
        collectionView;
    });
    
    self.fhwPageControl = ({
        FHWPageControl *v = [[FHWPageControl alloc] initWithFrame:CGRectMake(0, selfHeight -self.dotOffsetFoot, selfWidth, 4)];
        v.currentPage = 0;
        v.userInteractionEnabled=NO;
        
        v;
    });
    
    self.pageControl = ({
        UIPageControl *v = [[UIPageControl alloc] initWithFrame:CGRectMake(0, selfHeight - self.dotOffsetFoot, selfWidth, 20)];
        v.currentPageIndicatorTintColor = customDefaultColor;
        v.pageIndicatorTintColor = [UIColor whiteColor];
        v.currentPage = 0;
        v.userInteractionEnabled=NO;
        v.hidden = YES;
        
        v;
    });
    
    [self addSubview:self.collectionView];
    [self addSubview:self.pageControl];
    [self addSubview:self.fhwPageControl];
}

- (void)setup {
    @weakify(self);
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil]
      takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        imy_asyncMainBlock(^{
            @strongify(self);
            [self resumeAnimating];
        });
        
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil]
      takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        imy_asyncMainBlock(^{
            @strongify(self);
            [self pauseAnimating];
        });
    }];
}

- (void)loadData {
    if (self.models.count <= 1) {
        self.pageControl.hidden = YES;
        self.fhwPageControl.hidden = YES;
        [self.collectionView reloadData];
        return;
    }
    
    if (self.pageControlStyle == FHWCarouselPageControlStyleDot) {
        self.pageControl.numberOfPages = self.models.count;
        NSInteger pageControlWidth = [self.pageControl sizeForNumberOfPages:self.pageControl.numberOfPages].width;
        self.pageControl.imy_size = CGSizeMake(pageControlWidth, 30);
        [self setupPageControl:self.pageControl position:self.pageControlPosition];
    } else {
        self.fhwPageControl.numberOfPages = self.models.count;
        NSInteger pageControlWidth = [self.fhwPageControl sizeForNumberOfPages:self.fhwPageControl.numberOfPages].width;
        self.fhwPageControl.imy_size = CGSizeMake(pageControlWidth, 30);
        [self setupPageControl:self.fhwPageControl position:self.pageControlPosition];
    }
    [self.collectionView reloadData];
}

- (void)fixStartPosition {
    self.pageControl.currentPage = 0;
    if (self.models.count > 1) {
        NSInteger centerSection = self.isNotLoopPlay ? 0 : collectionViewSectionCount / 2;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:centerSection] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }  else {
        self.collectionView.contentOffset = CGPointZero;
    }
}

#pragma mark - Setter
- (void)setAnimationDuration:(NSTimeInterval)animationDuration {
    _animationDuration = animationDuration < 1 ? 1 : animationDuration;
}

- (void)setPageControlStyle:(FHWCarouselPageControlStyle)pageControlStyle {
    _pageControlStyle = pageControlStyle;
    self.pageControl.hidden = pageControlStyle != FHWCarouselPageControlStyleDot;
    self.fhwPageControl.hidden = pageControlStyle == FHWCarouselPageControlStyleDot;
}

- (void)setPageControlCurrentIndex:(NSInteger)index {
    if (self.pageControlStyle == FHWCarouselPageControlStyleDot) {
        self.pageControl.currentPage = index;
    } else {
        self.fhwPageControl.currentPage = index;
    }
}

- (void)setupPageControl:(UIView *)pageControl position:(FHWCarouselPageControlAt)position {
    switch (position) {
        case FHWCarouselPageControlAtCenter: {
            pageControl.center = CGPointMake(self.imy_width * 0.5, self.imy_height - 12);
            break;
        }
        case FHWCarouselPageControlAtLeft: {
            pageControl.imy_centerY = self.imy_height - 12;
            pageControl.imy_left = 10;
            break;
        }
        case FHWCarouselPageControlAtRight: {
            pageControl.imy_centerY = self.imy_height - 15;
            pageControl.imy_right = self.imy_width - 10;
            break;
        }
    }
}

#pragma mark - AnimationTimer
- (void)startAnimating {
    if (self.models.count <= 1 || self.isNotAutoPlay == YES) return;
    
    if (self.animationTimer) {
        [self resumeAnimating];
        return;
    }
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:_animationDuration
                                                           target:self
                                                         selector:@selector(animationTimerDidFired:)
                                                         userInfo:nil
                                                          repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.animationTimer forMode:NSRunLoopCommonModes];
}

- (void)animationTimerDidFired:(NSTimer *)timer {
    NSIndexPath *currentIndexPath = [self.collectionView indexPathsForVisibleItems].firstObject;
    NSInteger newItem = 0, newSection = 0;
    
    if (!self.isNotLoopPlay) {
        if (currentIndexPath.item == self.models.count - 1) {
            newSection = currentIndexPath.section + 1;
        } else {
            newItem = currentIndexPath.item + 1;
            newSection = currentIndexPath.section;
        }
    }
    
    if (currentIndexPath.section >= collectionViewSectionCount * 0.9 && currentIndexPath.item == 0) {
        newSection = collectionViewSectionCount / 2;
        [self fixStartPosition];
    }
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:newItem inSection:newSection] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

- (void)pauseAnimating {
    if (![self.animationTimer isValid]) return;
    self.animationTimer.fireDate = [NSDate distantFuture];
}

- (void)resumeAnimating {
    if (![self.animationTimer isValid]) return;
    self.animationTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:_animationDuration];
}

- (void)stopAnimating {
    if (!self.animationTimer) return;
    [self.animationTimer invalidate];
    self.animationTimer = nil;
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.models.count <= 1 || self.isNotLoopPlay) return 1;
    
    return collectionViewSectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHWCarouselCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FHWCarouselCell class])
                                                                      forIndexPath:indexPath];
    cell.defaultImage=self.defaultImage;
    cell.contentMode=self.contentMode;
    [cell updateWithData:self.models[indexPath.item]];
   
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.onDidClickEvent) {
        self.onDidClickEvent(indexPath.item);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.models.count <= 1) return;
    
    [self resumeAnimating];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.models.count <= 1)  return;
    
    if (decelerate == NO) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self pauseAnimating];
    self.draggingIndex = self.currentIndex;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSInteger offsetX = scrollView.contentOffset.x;
    NSInteger scrollViewWidth = scrollView.frame.size.width;
    
    NSInteger currentIndex;
    if (self.isNotLoopPlay) {
        currentIndex = (offsetX + 0.5 * scrollViewWidth) / scrollViewWidth;
        currentIndex = currentIndex >= self.models.count ? self.models.count - 1 : currentIndex;
    } else {
        currentIndex = (offsetX % (self.models.count * scrollViewWidth) + 0.5 * scrollViewWidth) / scrollViewWidth;
        currentIndex = currentIndex >= self.models.count ? 0 : currentIndex;
    }
    
    if (self.currentIndex == currentIndex) return;
    self.currentIndex = currentIndex;
    if (self.onDidScrollToIndex) {
        self.onDidScrollToIndex(currentIndex);
    }
    [self setPageControlCurrentIndex:self.currentIndex];
}

@end
