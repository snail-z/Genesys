import UIKit
import SnapKit

class ToolPanelViewController: UIViewController {
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.4, green: 0.5, blue: 0.7, alpha: 1.0)
        title = "工具面板"
        
        setupScrollView()
        setupStackView()
        createToolCards()
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        contentView = UIView()
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    private func setupStackView() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fill
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func createToolCards() {
        // 第一行：WiFi + CPU
        let row1 = createRow1()
        stackView.addArrangedSubview(row1)
        
        // 第二行：存储 + 芯片信息 + 日期
        let row2 = createRow2()
        stackView.addArrangedSubview(row2)
        
        // 第三行：垃圾清理 + 内存
        let row3 = createRow3()
        stackView.addArrangedSubview(row3)
        
        // 第四行：电量 + 时间
        let row4 = createRow4()
        stackView.addArrangedSubview(row4)
        
        // 第五行：开关控制
        let row5 = createRow5()
        stackView.addArrangedSubview(row5)
        
        // 第六行：设备信息
        let row6 = createRow6()
        stackView.addArrangedSubview(row6)
    }
    
    // MARK: - Row 1: WiFi + CPU
    private func createRow1() -> UIView {
        let container = UIView()
        container.snp.makeConstraints { make in
            make.height.equalTo(120)
        }
        
        let wifiCard = createWiFiCard()
        let cpuCard = createCPUCard()
        
        container.addSubview(wifiCard)
        container.addSubview(cpuCard)
        
        wifiCard.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.48)
        }
        
        cpuCard.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.48)
        }
        
        return container
    }
    
    private func createWiFiCard() -> UIView {
        let card = createCardView()
        
        let titleLabel = UILabel()
        titleLabel.text = "WiFi"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        
        let uploadLabel = UILabel()
        uploadLabel.text = "上传"
        uploadLabel.font = UIFont.systemFont(ofSize: 12)
        uploadLabel.textColor = .secondaryLabel
        
        let downloadLabel = UILabel()
        downloadLabel.text = "下载"
        downloadLabel.font = UIFont.systemFont(ofSize: 12)
        downloadLabel.textColor = .secondaryLabel
        
        let uploadSpeed = UILabel()
        uploadSpeed.text = "0.00 B/S"
        uploadSpeed.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        uploadSpeed.textColor = .label
        uploadSpeed.textAlignment = .right
        
        let downloadSpeed = UILabel()
        downloadSpeed.text = "0.00 B/S"
        downloadSpeed.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        downloadSpeed.textColor = .label
        downloadSpeed.textAlignment = .right
        
        let testButton = UIButton(type: .system)
        testButton.setTitle("开始测速", for: .normal)
        testButton.backgroundColor = .systemBlue
        testButton.setTitleColor(.white, for: .normal)
        testButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        testButton.layer.cornerRadius = 8
        
        card.addSubview(titleLabel)
        card.addSubview(uploadLabel)
        card.addSubview(downloadLabel)
        card.addSubview(uploadSpeed)
        card.addSubview(downloadSpeed)
        card.addSubview(testButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
        }
        
        uploadLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
        }
        
        uploadSpeed.snp.makeConstraints { make in
            make.centerY.equalTo(uploadLabel)
            make.right.equalToSuperview().offset(-16)
        }
        
        downloadLabel.snp.makeConstraints { make in
            make.top.equalTo(uploadLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
        }
        
        downloadSpeed.snp.makeConstraints { make in
            make.centerY.equalTo(downloadLabel)
            make.right.equalToSuperview().offset(-16)
        }
        
        testButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(28)
        }
        
        return card
    }
    
    private func createCPUCard() -> UIView {
        let card = createCardView()
        
        let titleLabel = UILabel()
        titleLabel.text = "CPU"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        
        let percentLabel = UILabel()
        percentLabel.text = "24%"
        percentLabel.font = UIFont.systemFont(ofSize: 32, weight: .light)
        percentLabel.textColor = .label
        
        let frequencyLabel = UILabel()
        frequencyLabel.text = "频率"
        frequencyLabel.font = UIFont.systemFont(ofSize: 12)
        frequencyLabel.textColor = .secondaryLabel
        
        let frequencyValue = UILabel()
        frequencyValue.text = "2.99GHz"
        frequencyValue.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        frequencyValue.textColor = .label
        
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0.24
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = UIColor.systemBlue.withAlphaComponent(0.2)
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        
        card.addSubview(titleLabel)
        card.addSubview(percentLabel)
        card.addSubview(frequencyLabel)
        card.addSubview(frequencyValue)
        card.addSubview(progressView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
        }
        
        percentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
        }
        
        frequencyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.right.equalToSuperview().offset(-16)
        }
        
        frequencyValue.snp.makeConstraints { make in
            make.top.equalTo(frequencyLabel.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-16)
        }
        
        progressView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(4)
        }
        
        return card
    }
    
    // MARK: - Row 2: 存储 + 芯片信息 + 日期
    private func createRow2() -> UIView {
        let container = UIView()
        container.snp.makeConstraints { make in
            make.height.equalTo(140)
        }
        
        let storageCard = createStorageCard()
        let chipCard = createChipCard()
        let dateCard = createDateCard()
        
        container.addSubview(storageCard)
        container.addSubview(chipCard)
        container.addSubview(dateCard)
        
        storageCard.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.48)
        }
        
        chipCard.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.48)
            make.height.equalTo(65)
        }
        
        dateCard.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.48)
            make.height.equalTo(65)
        }
        
        return container
    }
    
    private func createStorageCard() -> UIView {
        let card = createCardView()
        
        let titleLabel = UILabel()
        titleLabel.text = "存储"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        
        let percentLabel = UILabel()
        percentLabel.text = "67%"
        percentLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        percentLabel.textColor = .label
        percentLabel.textAlignment = .center
        
        let totalLabel = UILabel()
        totalLabel.text = "128GB"
        totalLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        totalLabel.textColor = .label
        totalLabel.textAlignment = .center
        
        let totalDesc = UILabel()
        totalDesc.text = "总量"
        totalDesc.font = UIFont.systemFont(ofSize: 10)
        totalDesc.textColor = .secondaryLabel
        totalDesc.textAlignment = .center
        
        let freeLabel = UILabel()
        freeLabel.text = "42GB"
        freeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        freeLabel.textColor = .label
        freeLabel.textAlignment = .center
        
        let freeDesc = UILabel()
        freeDesc.text = "剩余"
        freeDesc.font = UIFont.systemFont(ofSize: 10)
        freeDesc.textColor = .secondaryLabel
        freeDesc.textAlignment = .center
        
        // 圆形进度视图
        let circleView = CircularProgressView(progress: 0.67)
        
        card.addSubview(titleLabel)
        card.addSubview(circleView)
        card.addSubview(percentLabel)
        card.addSubview(totalLabel)
        card.addSubview(totalDesc)
        card.addSubview(freeLabel)
        card.addSubview(freeDesc)
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
        }
        
        circleView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.size.equalTo(60)
        }
        
        percentLabel.snp.makeConstraints { make in
            make.center.equalTo(circleView)
        }
        
        totalLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-24)
            make.left.equalToSuperview().offset(24)
        }
        
        totalDesc.snp.makeConstraints { make in
            make.top.equalTo(totalLabel.snp.bottom).offset(2)
            make.centerX.equalTo(totalLabel)
        }
        
        freeLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-24)
            make.right.equalToSuperview().offset(-24)
        }
        
        freeDesc.snp.makeConstraints { make in
            make.top.equalTo(freeLabel.snp.bottom).offset(2)
            make.centerX.equalTo(freeLabel)
        }
        
        return card
    }
    
    private func createChipCard() -> UIView {
        let card = createCardView()
        
        let logoView = UIView()
        logoView.backgroundColor = .black
        logoView.layer.cornerRadius = 8
        
        let appleLabel = UILabel()
        appleLabel.text = ""
        appleLabel.font = UIFont.systemFont(ofSize: 16)
        appleLabel.textColor = .white
        appleLabel.textAlignment = .center
        
        let chipLabel = UILabel()
        chipLabel.text = "A14 Bionic"
        chipLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        chipLabel.textColor = .label
        
        logoView.addSubview(appleLabel)
        card.addSubview(logoView)
        card.addSubview(chipLabel)
        
        logoView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
            make.size.equalTo(20)
        }
        
        appleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        chipLabel.snp.makeConstraints { make in
            make.centerY.equalTo(logoView)
            make.left.equalTo(logoView.snp.right).offset(12)
        }
        
        return card
    }
    
    private func createDateCard() -> UIView {
        let card = createCardView()
        
        let monthLabel = UILabel()
        monthLabel.text = "8月"
        monthLabel.font = UIFont.systemFont(ofSize: 12)
        monthLabel.textColor = .secondaryLabel
        monthLabel.textAlignment = .center
        
        let dayLabel = UILabel()
        dayLabel.text = "27"
        dayLabel.font = UIFont.systemFont(ofSize: 32, weight: .light)
        dayLabel.textColor = .label
        dayLabel.textAlignment = .center
        
        card.addSubview(monthLabel)
        card.addSubview(dayLabel)
        
        monthLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
        }
        
        dayLabel.snp.makeConstraints { make in
            make.top.equalTo(monthLabel.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
        
        return card
    }
    
    // MARK: - Row 3: 垃圾清理 + 内存
    private func createRow3() -> UIView {
        let container = UIView()
        container.snp.makeConstraints { make in
            make.height.equalTo(120)
        }
        
        let cleanCard = createCleanCard()
        let memoryCard = createMemoryCard()
        
        container.addSubview(cleanCard)
        container.addSubview(memoryCard)
        
        cleanCard.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.48)
        }
        
        memoryCard.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.48)
        }
        
        return container
    }
    
    private func createCleanCard() -> UIView {
        let card = createCardView()
        
        let titleLabel = UILabel()
        titleLabel.text = "喇叭清灰"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "给喇叭定期清灰"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = .label
        
        let descLabel = UILabel()
        descLabel.text = "预防喇叭堵塞"
        descLabel.font = UIFont.systemFont(ofSize: 12)
        descLabel.textColor = .secondaryLabel
        
        let cleanButton = UIButton(type: .system)
        cleanButton.setTitle("开始清灰", for: .normal)
        cleanButton.backgroundColor = .systemGreen
        cleanButton.setTitleColor(.white, for: .normal)
        cleanButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        cleanButton.layer.cornerRadius = 16
        
        card.addSubview(titleLabel)
        card.addSubview(subtitleLabel)
        card.addSubview(descLabel)
        card.addSubview(cleanButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(16)
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(16)
        }
        
        cleanButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(32)
        }
        
        return card
    }
    
    private func createMemoryCard() -> UIView {
        let card = createCardView()
        
        let titleLabel = UILabel()
        titleLabel.text = "内存"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        
        let percentLabel = UILabel()
        percentLabel.text = "72%"
        percentLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        percentLabel.textColor = .label
        percentLabel.textAlignment = .center
        
        let freeLabel = UILabel()
        freeLabel.text = "空闲"
        freeLabel.font = UIFont.systemFont(ofSize: 10)
        freeLabel.textColor = .secondaryLabel
        
        let freeValue = UILabel()
        freeValue.text = "0.98GB"
        freeValue.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        freeValue.textColor = .label
        
        let totalLabel = UILabel()
        totalLabel.text = "总量"
        totalLabel.font = UIFont.systemFont(ofSize: 10)
        totalLabel.textColor = .secondaryLabel
        
        let totalValue = UILabel()
        totalValue.text = "3.58GB"
        totalValue.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        totalValue.textColor = .label
        
        // 圆形进度视图
        let circleView = CircularProgressView(progress: 0.72)
        
        card.addSubview(titleLabel)
        card.addSubview(circleView)
        card.addSubview(percentLabel)
        card.addSubview(freeLabel)
        card.addSubview(freeValue)
        card.addSubview(totalLabel)
        card.addSubview(totalValue)
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
        }
        
        circleView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.size.equalTo(50)
        }
        
        percentLabel.snp.makeConstraints { make in
            make.center.equalTo(circleView)
        }
        
        freeLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-24)
            make.left.equalToSuperview().offset(24)
        }
        
        freeValue.snp.makeConstraints { make in
            make.top.equalTo(freeLabel.snp.bottom).offset(2)
            make.centerX.equalTo(freeLabel)
        }
        
        totalLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-24)
            make.right.equalToSuperview().offset(-24)
        }
        
        totalValue.snp.makeConstraints { make in
            make.top.equalTo(totalLabel.snp.bottom).offset(2)
            make.centerX.equalTo(totalLabel)
        }
        
        return card
    }
    
    // MARK: - Row 4: 电量 + 时间
    private func createRow4() -> UIView {
        let container = UIView()
        container.snp.makeConstraints { make in
            make.height.equalTo(140)
        }
        
        let batteryCard = createBatteryCard()
        let timeCard = createTimeCard()
        
        container.addSubview(batteryCard)
        container.addSubview(timeCard)
        
        batteryCard.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.32)
            make.height.equalTo(120)
        }
        
        timeCard.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.64)
            make.height.equalTo(50)
        }
        
        return container
    }
    
    private func createBatteryCard() -> UIView {
        let card = createCardView()
        
        let titleLabel = UILabel()
        titleLabel.text = "电量"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        
        // 使用真实水波进度视图 - 小一点，快一点的波浪
        let waveProgressView = RealisticWaveView.batteryStyle(waveAmplitude: 0.8, waveSpeed: 1.4)
        waveProgressView.layer.cornerRadius = 8
        
        card.addSubview(titleLabel)
        card.addSubview(waveProgressView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
        }
        
        waveProgressView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        
        // 延迟设置进度，让界面更加生动 - 水从底部慢慢上涨到55%，过程中波浪持续动态
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            waveProgressView.setProgress(0.55, animated: true, duration: 4.0)
        }
        
        return card
    }
    
    private func createTimeCard() -> UIView {
        let card = createCardView()
        
        let timeLabel = UILabel()
        timeLabel.text = "上午 6:56"
        timeLabel.font = UIFont.systemFont(ofSize: 20, weight: .light)
        timeLabel.textColor = .label
        timeLabel.textAlignment = .center
        
        card.addSubview(timeLabel)
        
        timeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return card
    }
    
    // MARK: - Row 5: 开关控制
    private func createRow5() -> UIView {
        let container = UIView()
        container.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        let hotspotCard = createSwitchCard(title: "📶", subtitle: "ON", isOn: true)
        let wifiCard = createSwitchCard(title: "📶", subtitle: "ON", isOn: true)
        let bluetoothCard = createSwitchCard(title: "📘", subtitle: "ON", isOn: true)
        let dndCard = createSwitchCard(title: "⭕", subtitle: "0%", isOn: false)
        
        container.addSubview(hotspotCard)
        container.addSubview(wifiCard)
        container.addSubview(bluetoothCard)
        container.addSubview(dndCard)
        
        hotspotCard.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.23)
        }
        
        wifiCard.snp.makeConstraints { make in
            make.left.equalTo(hotspotCard.snp.right).offset(8)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.23)
        }
        
        bluetoothCard.snp.makeConstraints { make in
            make.left.equalTo(wifiCard.snp.right).offset(8)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.23)
        }
        
        dndCard.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.23)
        }
        
        return container
    }
    
    private func createSwitchCard(title: String, subtitle: String, isOn: Bool) -> UIView {
        let card = createCardView()
        
        let iconLabel = UILabel()
        iconLabel.text = title
        iconLabel.font = UIFont.systemFont(ofSize: 20)
        iconLabel.textAlignment = .center
        
        let statusLabel = UILabel()
        statusLabel.text = subtitle
        statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        statusLabel.textColor = isOn ? .systemGreen : .secondaryLabel
        statusLabel.textAlignment = .center
        
        card.addSubview(iconLabel)
        card.addSubview(statusLabel)
        
        iconLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
        }
        
        return card
    }
    
    // MARK: - Row 6: 设备信息
    private func createRow6() -> UIView {
        let container = UIView()
        container.snp.makeConstraints { make in
            make.height.equalTo(180)
        }
        
        let batteryInfoCard = createBatteryInfoCard()
        let timeInfoCard = createTimeInfoCard()
        let deviceCard = createDeviceCard()
        
        container.addSubview(batteryInfoCard)
        container.addSubview(timeInfoCard)
        container.addSubview(deviceCard)
        
        batteryInfoCard.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.48)
            make.height.equalTo(50)
        }
        
        timeInfoCard.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalTo(batteryInfoCard.snp.bottom).offset(8)
            make.width.equalToSuperview().multipliedBy(0.48)
            make.height.equalTo(50)
        }
        
        deviceCard.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.48)
            make.height.equalTo(110)
        }
        
        return container
    }
    
    private func createBatteryInfoCard() -> UIView {
        let card = createCardView()
        
        let capacityLabel = UILabel()
        capacityLabel.text = "2815mAh"
        capacityLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        capacityLabel.textColor = .label
        
        let descLabel = UILabel()
        descLabel.text = "电池容量"
        descLabel.font = UIFont.systemFont(ofSize: 12)
        descLabel.textColor = .secondaryLabel
        
        card.addSubview(capacityLabel)
        card.addSubview(descLabel)
        
        capacityLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
        }
        
        descLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-12)
            make.centerX.equalToSuperview()
        }
        
        return card
    }
    
    private func createTimeInfoCard() -> UIView {
        let card = createCardView()
        
        let timeLabel = UILabel()
        timeLabel.text = "9时20分"
        timeLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        timeLabel.textColor = .label
        
        let descLabel = UILabel()
        descLabel.text = "电量预计可用"
        descLabel.font = UIFont.systemFont(ofSize: 12)
        descLabel.textColor = .secondaryLabel
        
        card.addSubview(timeLabel)
        card.addSubview(descLabel)
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
        }
        
        descLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-12)
            make.centerX.equalToSuperview()
        }
        
        return card
    }
    
    private func createDeviceCard() -> UIView {
        let card = createCardView()
        
        let versionLabel = UILabel()
        versionLabel.text = "当前版本 17.1"
        versionLabel.font = UIFont.systemFont(ofSize: 12)
        versionLabel.textColor = .secondaryLabel
        
        let deviceIcon = UIView()
        deviceIcon.backgroundColor = .systemRed
        deviceIcon.layer.cornerRadius = 8
        
        let deviceLabel = UILabel()
        deviceLabel.text = "iPhone"
        deviceLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        deviceLabel.textColor = .label
        
        let modelLabel = UILabel()
        modelLabel.text = "iPhone 12"
        modelLabel.font = UIFont.systemFont(ofSize: 14)
        modelLabel.textColor = .secondaryLabel
        
        card.addSubview(versionLabel)
        card.addSubview(deviceIcon)
        card.addSubview(deviceLabel)
        card.addSubview(modelLabel)
        
        versionLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
        }
        
        deviceIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-24)
            make.size.equalTo(24)
        }
        
        deviceLabel.snp.makeConstraints { make in
            make.left.equalTo(deviceIcon.snp.right).offset(12)
            make.top.equalTo(deviceIcon)
        }
        
        modelLabel.snp.makeConstraints { make in
            make.left.equalTo(deviceLabel)
            make.top.equalTo(deviceLabel.snp.bottom).offset(2)
        }
        
        return card
    }
    
    // MARK: - Helper Methods
    private func createCardView() -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 8
        card.layer.shadowOpacity = 0.1
        return card
    }
}

// MARK: - Custom Circular Progress View
class CircularProgressView: UIView {
    
    private var progressLayer: CAShapeLayer!
    private var trackLayer: CAShapeLayer!
    private let progress: CGFloat
    
    init(progress: CGFloat) {
        self.progress = progress
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        self.progress = 0.0
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        // Track layer (背景圆环)
        trackLayer = CAShapeLayer()
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.systemGray5.cgColor
        trackLayer.lineWidth = 6
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        // Progress layer (进度圆环)
        progressLayer = CAShapeLayer()
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.systemGreen.cgColor
        progressLayer.lineWidth = 6
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = progress
        layer.addSublayer(progressLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (min(bounds.width, bounds.height) - 6) / 2
        
        let circularPath = UIBezierPath(arcCenter: center,
                                       radius: radius,
                                       startAngle: -.pi / 2,
                                       endAngle: 3 * .pi / 2,
                                       clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
    }
}