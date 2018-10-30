//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport

class MyViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellid = "id"

    
    override init(collectionViewLayout layout: UICollectionViewLayout = UICollectionViewFlowLayout()) {
        super.init(collectionViewLayout: layout)
        collectionView = UICollectionView(frame:  CGRect(x: 150, y: 200, width: 200, height: 20), collectionViewLayout: layout)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .white
        collectionView?.register(StackViewCell.self, forCellWithReuseIdentifier: cellid)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellid, for: indexPath) as! StackViewCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = UICollectionReusableView()
        header.backgroundColor = .green
        return header
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let view = view else { return CGSize(width: 50, height: 50) }
        return CGSize(width: view.bounds.width, height: 250)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        view = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
}

class StackCardLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // 获取这个范围的布局数组
        let attributes = super.layoutAttributesForElements(in: rect)
        // 找到中心点
        let centerX = collectionView!.contentOffset.x + collectionView!.bounds.width / 2
        
        // 每个点根据距离中心点距离进行缩放
        attributes!.forEach({ (attr) in
            let pad = abs(centerX - attr.center.x)
            let scale = 1.8 - pad / collectionView!.bounds.width
            attr.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
        return attributes
    }
    
    /// 重写滚动时停下的位置
    ///
    /// - Parameters:
    ///   - proposedContentOffset: 将要停止的点
    ///   - velocity: 滚动速度
    /// - Returns: 滚动停止的点
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var targetPoint = proposedContentOffset
        
        // 中心点
        let centerX = proposedContentOffset.x + collectionView!.bounds.width
        
        // 获取这个范围的布局数组
        let attributes = self.layoutAttributesForElements(in: CGRect(x: proposedContentOffset.x, y: proposedContentOffset.y, width: collectionView!.bounds.width, height: collectionView!.bounds.height))
        
        // 需要移动的最小距离
        var moveDistance: CGFloat = CGFloat(MAXFLOAT)
        // 遍历数组找出最小距离
        attributes!.forEach { (attr) in
            if abs(attr.center.x - centerX) < abs(moveDistance) {
                moveDistance = attr.center.x - centerX
            }
        }
        // 只有在ContentSize范围内，才进行移动
        if targetPoint.x > 0 && targetPoint.x < collectionViewContentSize.width - collectionView!.bounds.width {
            targetPoint.x += moveDistance
        }
        
        return targetPoint
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width:sectionInset.left + sectionInset.right + (CGFloat(collectionView!.numberOfItems(inSection: 0)) * (itemSize.width + minimumLineSpacing)) - minimumLineSpacing, height: 0)
    }
}

class CardCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        layer.cornerRadius = 10
        backgroundColor = .green
        contentMode = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class StackViewCell: UICollectionViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard let indexPath = collectionView.indexPathForItem(at: contentView.convert((collectionView.center), to: collectionView)), let cell = collectionView.cellForItem(at: indexPath) else { return }
//        collectionView.bringSubview(toFront: cell)
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: String(describing: self))
        contentView.addSubview(collectionView)
        backgroundColor = .red
        
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = CoverFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = -285
        
        layout.itemSize = CGSize(width: contentView.frame.width/1.2, height: contentView.frame.height/1.2)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        let cv = UICollectionView(frame: contentView.frame, collectionViewLayout: layout)
//        cv.isPagingEnabled = true
//        cv.contentSize = CGSize(width: 50, height: 50)
//        cv.contentOffset = CGPoint(x: 50, y: 50)
        
        cv.contentSize = CGSize(width: contentView.frame.width*2, height: contentView.frame.height)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .blue
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    var delegate: UICollectionViewController?
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: contentView.frame.width/1.2, height: contentView.frame.height/1.2-10)
//    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       return collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: self), for: indexPath) as! CardCell
    }
    
    
}


class CoverFlowLayout: UICollectionViewFlowLayout {
    
  
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { return true }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let centerX = (collectionView!.contentOffset.x + collectionView!.bounds.size.width * 0.5)
        return super.layoutAttributesForElements(in: rect)?.map {
            
            let scale = 1 / (1 + abs($0.center.x - centerX) * 0.0045)
//            $0.size = itemSize
            $0.transform = CGAffineTransform(scaleX: scale, y: scale)
            $0.alpha = scale
            return $0
        }
    }
    
//    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//
//        var finalContentOffset = proposedContentOffset
//
//        // 每單位偏移量對應的偏移角度
//        let factor = -angleAtextreme / (collectionViewContentSize.width - collectionView!.bounds.width)
//        let proposedAngle = proposedContentOffset.x * factor
//
//        // 大約偏移了多少個
//        let ratio = proposedAngle / anglePerItem
//
//        var multiplier: CGFloat
//
//        // 往左滑動,讓multiplier成為整個
//        if velocity.x > 0 {
//            multiplier = ceil(ratio)
//        } else if (velocity.x < 0) {  // 往右滑動
//            multiplier = floor(ratio)
//        } else {
//            multiplier = round(ratio)
//        }
//
//        finalContentOffset.x = multiplier * anglePerItem / factor
//
//        return finalContentOffset
//
//    }
    
//    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
//        guard let layoutAttributes = super.layoutAttributesForElements(in: CGRect(
//            x: proposedContentOffset.x,
//            y: proposedContentOffset.y,
//            width: collectionView!.bounds.size.width,
//            height: collectionView!.bounds.size.height)),
//            !layoutAttributes.isEmpty else { return .zero }
//
//        let centerX = proposedContentOffset.x + collectionView!.bounds.size.width * 0.5,
//        offsetX = layoutAttributes.reduce(layoutAttributes[0]) { return abs($1.center.x - centerX) < abs($0.center.x - centerX) ? $1 : $0 }.center.x - centerX
//        return CGPoint( x: proposedContentOffset.x + offsetX, y: proposedContentOffset.y)
//    }
}



// Present the view controller in the Live View window
//PlaygroundPage.current.liveView = MyViewController(collectionViewLayout: StackCardLayout())
//PlaygroundPage.current.liveView = MyViewController(collectionViewLayout: CoverFlowLayout())
PlaygroundPage.current.liveView = MyViewController()
