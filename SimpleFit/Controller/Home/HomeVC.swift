//
//  ViewController.swift
//  SimpleFit
//
//  Created by shuo on 2020/11/26.
//

import UIKit
import AAInfographics
import SideMenu

class HomeVC: UIViewController {
    
    private struct Segue {
        
        static let sideMenuNC = "SegueSideMenuNC"
        static let datePicker = "SegueDatePicker"
        static let detail = "SegueDetail"
        static let addWeight = "SegueAddWeight"
    }
    
    let chartView = AAChartView()
    var chartModel = AAChartModel()
    var chartOptions = AAOptions()
    let dataProvider = ChartDataProvider()
    var selectedYear = Date().year()
    var selectedMonth = Date().month()
    let pickMonthButton = UIButton()
    let sideMenuButton = UIButton()
    var addMenuButton = UIButton()
    var weightButton = UIButton()
    var cameraButton = UIButton()
    var albumButton = UIButton()
    var noteButton = UIButton()
    var isAddMenuOpen = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNC()
        configureChart()
        configureSideMenu()
    }
    
    private func configureLayout() {
        
        sideMenuButton.setImage(UIImage.asset(.sideMenu), for: .normal)
        sideMenuButton.addTarget(self, action: #selector(showSideMenu), for: .touchUpInside)
        
        pickMonthButton.addTarget(self, action: #selector(showPickMonthPage), for: .touchUpInside)
        
        addMenuButton.setImage(UIImage.asset(.add), for: .normal)
        addMenuButton.addTarget(self, action: #selector(toggleAddMenu), for: .touchUpInside)
        
        view.addSubview(pickMonthButton)
        view.addSubview(sideMenuButton)
        view.addSubview(addMenuButton)
        
        addMenuButton.applyAddButton()
        sideMenuButton.applySideMenuButton()
        pickMonthButton.applyPickMonthButtonFor(month: selectedMonth)
    }
    
    private func configureNC() { navigationController?.navigationBar.isHidden = true }
    
    private func configureChart() {
        
        configureChartModel()
        configureChartView()
        chartView.aa_drawChartWithChartOptions(chartOptions)//圖表視圖對象調用圖表模型對象,繪制最終圖形
    }
    
    private func configureChartView() {
        
        let chartViewWidth  = view.frame.size.width
        let chartViewHeight = view.frame.size.height - 80
        chartView.frame = CGRect(x: 0, y: 0, width: chartViewWidth, height: chartViewHeight)
        chartView.delegate = self
        view.addSubview(chartView)
    }
    
    private func configureChartModel() {
        
        let chartData = dataProvider.getDataFor(year: selectedYear, month: selectedMonth)
        
        guard let min = chartData.min,
              let max = chartData.max,
              let categories = chartData.categories,
              let weightsData = chartData.datas
        else { return }
        
        chartModel = AAChartModel()
            .animationDuration(1200)
            .categories(categories)
            .chartType(.spline)//圖表類型
            .colorsTheme(["#c0c0c0"])
            .dataLabelsEnabled(true)//數據標簽是否顯示
            .dataLabelsFontColor("gray")
            .dataLabelsFontSize(18)
            .dataLabelsFontWeight(.bold)
            .inverted(false)//是否翻轉圖形
            .legendEnabled(false)//是否啟用圖表的圖例(圖表底部的可點擊的小圓點)
            .markerRadius(10)//連接點大小
            .markerSymbolStyle(.borderBlank)//折線或者曲線的連接點是否為空心的
            .scrollablePlotArea(AAScrollablePlotArea().minWidth(2000).scrollPositionX(0))
            .series([AASeriesElement().name("體重").data(weightsData)])
//            .subtitle("2020年11月")//圖表副標題
//            .title("Simple Fit")//圖表主標題
            .tooltipValueSuffix("公斤")//浮動提示框單位後綴
            .tooltipEnabled(true)//是否顯示浮動提示框
            .touchEventEnabled(true)//是否支持觸摸事件回調
            .yAxisLabelsEnabled(false)//y 軸是否顯示數據
            .yAxisMin(min)
            .yAxisMax(max)
        
        let crosshair = AACrosshair().width(0.01)
        chartOptions = chartModel.aa_toAAOptions()
        chartOptions.xAxis?.crosshair(crosshair)
    }
    
    private func updateChartFor(year: Int, month: Int) {
        
        pickMonthButton.setTitle("\(month)月", for: .normal)
        self.selectedYear = year
        self.selectedMonth = month
        configureChart()
        configureLayout()
    }
    
    private func configureSideMenu() {
        
        let sideMenuNC = storyboard?.instantiateViewController(withIdentifier: "SideMenuNC")
        SideMenuManager.default.leftMenuNavigationController = sideMenuNC as? SideMenuNavigationController
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
        SideMenuManager.default.leftMenuNavigationController?.settings = makeSettings()
        
        configureLayout()
    }
    
    private func showImagePicker(type: UIImagePickerController.SourceType) {
        
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @objc private func showSideMenu() {
        
        if isAddMenuOpen { toggleAddMenu() }
        performSegue(withIdentifier: Segue.sideMenuNC, sender: nil)
    }
    
    @objc private func toggleAddMenu() {
        
        let buttons = [noteButton, albumButton, cameraButton, weightButton]
        var padding: CGFloat = 70
        
        weightButton.setImage(UIImage.asset(.weight), for: .normal)
        cameraButton.setImage(UIImage.asset(.camera), for: .normal)
        albumButton.setImage(UIImage.asset(.album), for: .normal)
        noteButton.setImage(UIImage.asset(.note), for: .normal)
        
        weightButton.addTarget(self, action: #selector(showAddWeight), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(showCamera), for: .touchUpInside)
        albumButton.addTarget(self, action: #selector(showAlbum), for: .touchUpInside)
        
        buttons.forEach {
            view.addSubview($0)
            $0.applyAddMenuButton()
            
            $0.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                $0.centerXAnchor.constraint(equalTo: addMenuButton.centerXAnchor),
                $0.centerYAnchor.constraint(equalTo: addMenuButton.centerYAnchor)
            ])
        }
        
        if isAddMenuOpen {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: { [weak self] in
                self?.addMenuButton.transform = .identity
                
                buttons.forEach {
                    $0.alpha = 0
                    $0.transform = CGAffineTransform(translationX: 0, y: padding)
                    padding += 70
                }
            })
            isAddMenuOpen = false
        } else {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: { [weak self] in
                self?.addMenuButton.transform = CGAffineTransform(rotationAngle: .pi * 1.25)
                
                buttons.forEach {
                    $0.alpha = 1
                    $0.transform = CGAffineTransform(translationX: 0, y: -padding)
                    padding += 70
                }
            })
            isAddMenuOpen = true
        }
    }
    
    @objc private func showPickMonthPage() {
        
        if isAddMenuOpen { toggleAddMenu() }
        performSegue(withIdentifier: Segue.datePicker, sender: nil)
    }
    
    @objc private func showAddWeight() {
        
        toggleAddMenu()
        performSegue(withIdentifier: Segue.addWeight, sender: nil)
    }
    
    @objc private func showCamera() {
        
        toggleAddMenu()
        if UIImagePickerController.isSourceTypeAvailable(.camera) { showImagePicker(type: .camera) }
    }
    
    @objc private func showAlbum() {
        
        if isAddMenuOpen { toggleAddMenu() }
        showImagePicker(type: .photoLibrary)
    }
    
    private func makeSettings() -> SideMenuSettings {
        
        let presentationStyle = SideMenuPresentationStyle.menuSlideIn
        presentationStyle.menuStartAlpha = 0.1
        presentationStyle.presentingEndAlpha = 0.8
        presentationStyle.onTopShadowOpacity = 0.5
        
        var settings = SideMenuSettings()
        settings.presentationStyle = presentationStyle
        settings.presentDuration = 1
        settings.dismissDuration = 1
        settings.blurEffectStyle = .systemChromeMaterial
        settings.menuWidth = view.frame.width - 100

        return settings
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        
        case Segue.sideMenuNC:
            guard let sideMenuNC = segue.destination as? SideMenuNavigationController else { return }
            sideMenuNC.settings = makeSettings()
        case Segue.datePicker:
            guard let datePickerVC = segue.destination as? DatePickerVC else { return }
            datePickerVC.selectedYear = self.selectedYear
            datePickerVC.selectedMonth = self.selectedMonth
            datePickerVC.callback = { [weak self] (selectedYear, selectedMonth, isCancel) in
                let isDifferentDate = self?.selectedYear != selectedYear || self?.selectedMonth != selectedMonth
                if !isCancel && isDifferentDate { self?.updateChartFor(year: selectedYear, month: selectedMonth) }
            }
        default: break
        }
    }
}

extension HomeVC: AAChartViewDelegate {
    
    func aaChartView(_ aaChartView: AAChartView, moveOverEventMessage: AAMoveOverEventMessageModel) {
        
        if isAddMenuOpen { toggleAddMenu() }
        performSegue(withIdentifier: Segue.detail, sender: nil)
    }
}
