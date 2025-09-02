import UIKit

protocol CalendarGridViewDelegate: AnyObject {
    func didSelectDate(_ date: Date)
    func didChangeMonth(_ date: Date)
}

class CalendarGridView: UIView {
    
    // MARK: - 属性
    weak var delegate: CalendarGridViewDelegate?
    private let dataManager = CalendarDataManager.shared
    
    private var currentDate = Date()
    private var selectedDate = Date()
    
    // MARK: - UI组件
    private var collectionView: UICollectionView!
    private var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: - 数据源
    private var monthsData: [Date] = []
    
    // MARK: - 配置常量
    private let totalMonths = 240 // 总月份数量 (-120 到 +120)
    private let centerIndex = 120 // 中心索引
    private let cellIdentifier = "MonthCell"
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupData()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupData()
    }
    
    // MARK: - UI设置
    private func setupUI() {
        backgroundColor = .systemBackground
        setupCollectionView()
        setupConstraints()
    }
    
    private func setupCollectionView() {
        // 创建流布局
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets.zero
        
        // 创建CollectionView
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceHorizontal = true
        
        // 设置代理和数据源
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // 注册Cell
        collectionView.register(MonthCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupData() {
        generateMonthsData()
        
        // 延迟滚动到当前月份，确保布局完成
        DispatchQueue.main.async {
            self.scrollToCurrentMonth(animated: false)
        }
    }
    
    private func generateMonthsData() {
        monthsData.removeAll()
        
        let calendar = Calendar.current
        let baseDate = Date()
        
        // 生成从-120到+120个月的数据
        for i in -centerIndex...centerIndex {
            if let monthDate = calendar.date(byAdding: .month, value: i, to: baseDate) {
                monthsData.append(monthDate)
            }
        }
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 确保item尺寸正确
        if !bounds.isEmpty {
            flowLayout.itemSize = bounds.size
        }
    }
    
    // MARK: - 公共方法
    func updateSelectedDate(_ date: Date) {
        let oldSelectedDate = selectedDate
        selectedDate = date
        
        // 只重新加载受影响的cells，提高性能
        reloadVisibleCellsIfNeeded(oldDate: oldSelectedDate, newDate: date)
    }
    
    private func reloadVisibleCellsIfNeeded(oldDate: Date, newDate: Date) {
        let calendar = Calendar.current
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        
        for indexPath in visibleIndexPaths {
            let monthDate = monthsData[indexPath.item]
            
            // 检查这个月是否包含旧的或新的选中日期
            let containsOldDate = calendar.isDate(oldDate, equalTo: monthDate, toGranularity: .month)
            let containsNewDate = calendar.isDate(newDate, equalTo: monthDate, toGranularity: .month)
            
            if containsOldDate || containsNewDate {
                if let cell = collectionView.cellForItem(at: indexPath) as? MonthCollectionViewCell {
                    cell.updateSelectedDate(newDate)
                }
            }
        }
    }
    
    func scrollToToday(animated: Bool = true) {
        let today = Date()
        currentDate = today
        selectedDate = today
        
        scrollToCurrentMonth(animated: animated)
        updateSelectedDate(today)
    }
    
    func navigateToMonth(_ direction: Int) {
        guard let currentIndexPath = getCurrentVisibleIndexPath() else { return }
        
        let currentItem = currentIndexPath.item
        let targetItem = max(0, min(monthsData.count - 1, currentItem + direction))
        let targetIndexPath = IndexPath(item: targetItem, section: 0)
        
        collectionView.scrollToItem(at: targetIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    private func scrollToCurrentMonth(animated: Bool) {
        let targetIndexPath = IndexPath(item: centerIndex, section: 0)
        collectionView.scrollToItem(at: targetIndexPath, at: .centeredHorizontally, animated: animated)
    }
    
    private func getCurrentVisibleIndexPath() -> IndexPath? {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        return visibleIndexPaths.first
    }
    
    // MARK: - 月份更新
    private func updateCurrentMonthFromScroll() {
        let pageWidth = collectionView.bounds.width
        let currentOffset = collectionView.contentOffset.x
        let currentPage = Int(round(currentOffset / pageWidth))
        
        if currentPage >= 0 && currentPage < monthsData.count {
            let newDate = monthsData[currentPage]
            if !Calendar.current.isDate(currentDate, equalTo: newDate, toGranularity: .month) {
                currentDate = newDate
                delegate?.didChangeMonth(newDate)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CalendarGridView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return monthsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MonthCollectionViewCell
        
        let monthDate = monthsData[indexPath.item]
        cell.configure(currentDate: monthDate, selectedDate: selectedDate)
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CalendarGridView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

// MARK: - UIScrollViewDelegate
extension CalendarGridView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentMonthFromScroll()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentMonthFromScroll()
    }
    
    // 平滑滚动支持
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageWidth = collectionView.bounds.width
        let targetX = targetContentOffset.pointee.x
        let targetPage = round(targetX / pageWidth)
        
        targetContentOffset.pointee.x = targetPage * pageWidth
    }
}

// MARK: - MonthCollectionViewCellDelegate
extension CalendarGridView: MonthCollectionViewCellDelegate {
    func didSelectDate(_ date: Date) {
        updateSelectedDate(date)
        delegate?.didSelectDate(date)
    }
}