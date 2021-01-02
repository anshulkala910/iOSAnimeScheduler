//
//  AnalysisViewController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/12/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit
import Charts
public class BarChartFormatter: NSObject, IAxisValueFormatter {
    
    var values = [String]()
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return values[Int(value)]
    }
    public func setValues(values: [String])
    {
        self.values = values
    }
    
    
}
class AnalysisViewController: UIViewController {
    
    @IBOutlet weak var analysisTableView: UITableView!
    static var shouldCountHoursSpent = true
    @IBOutlet weak var fakeLabel: UILabel!
    
    let columnNames = ["Completed", "Currently Watching","Hours Spent"]
    var columnAnswers = ["0","0","0"]
    
    var barChart = BarChartView()
    
    var days = ["1","2","3","4","5","6","7"]
    var hoursForDays = [1.0,2.0,3.0,4.0,5.0,6.0,7.0]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        analysisTableView.delegate = self
        analysisTableView.dataSource = self
        
        barChart.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fakeLabel.isHidden = true
        if AnalysisViewController.shouldCountHoursSpent == true {
            columnAnswers[0] = String(HomeViewController.completedAnimeTemp.count)
            columnAnswers[1] = String(HomeViewController.currentlyWatchingAnimeTemp.count)
            columnAnswers[2] = getHoursSpent()
            fillChartData()
            self.analysisTableView.reloadData()
        }
        AnalysisViewController.shouldCountHoursSpent = false
        fillChartData()
        setChart(dataPoints: days, values: hoursForDays)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        barChart.frame = CGRect(x: fakeLabel.frame.origin.x, y: fakeLabel.frame.origin.y, width: fakeLabel.frame.width, height: fakeLabel.frame.height)
        view.addSubview(barChart)
    }
    
    
    func setChart(dataPoints: [String], values: [Double])
    {
        let formatter = BarChartFormatter()
        formatter.setValues(values: dataPoints)
        let xaxis:XAxis = XAxis()


        var dataEntries: [BarChartDataEntry] = []

        for i in 0..<dataPoints.count
        {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }

        let chartDataSet = BarChartDataSet(entries: dataEntries)

        let chartData = BarChartData(dataSet: chartDataSet)

        barChart.drawGridBackgroundEnabled = false
        barChart.dragEnabled = false
        
        let xAxis = barChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.labelCount = 7
        xAxis.axisMaxLabels = 7
        xAxis.drawGridLinesEnabled = false
        
        let leftAxis = barChart.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0
        leftAxis.drawGridLinesEnabled = false
        barChart.rightAxis.enabled = false
        barChart.doubleTapToZoomEnabled = false
        barChart.dragXEnabled = false
        barChart.dragYEnabled = false
        barChart.pinchZoomEnabled = false
        barChart.scaleXEnabled = false
        barChart.scaleYEnabled = false
        xaxis.valueFormatter = formatter
        barChart.xAxis.labelPosition = .bottom
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.xAxis.valueFormatter = xaxis.valueFormatter
        barChart.chartDescription?.enabled = false
        barChart.legend.enabled = false
        barChart.data = chartData
    }
    
    func fillChartData() {
        let currentDate = Date()
        let currentDay = getDateComponent(date: currentDate, .day)
        days[6] = String(currentDay)
        hoursForDays[6] = populateDateArrays(currentDate)
        for range in 1...6 {
            let newDate = Calendar.current.date(byAdding: .day, value: 0 - Int(range), to: currentDate)
            days[6-range] = String(getDateComponent(date: newDate ?? currentDate, .day))
            hoursForDays[6-range] = populateDateArrays(newDate ?? currentDate)
        }
        
    }
    func getHoursSpent() -> String {
        var minutesSpent = 0
        for anime in HomeViewController.completedAnimeTemp {
            minutesSpent += Int(anime.episodes*anime.episodeLength)
        }
        for anime in HomeViewController.currentlyWatchingAnimeTemp {
            minutesSpent += Int(anime.episodesFinished*anime.episodeLength)
        }
        let minutes = minutesSpent % 60
        let hours = minutesSpent/60
        return "\(hours) hrs \(minutes) mins"
    }

    
    /*
     This function returns the date component of a particular Date instnace
     parameters: date, date component, calendar
     returns: integer representing date component
     */
    func getDateComponent(date: Date, _ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: date)
    }
    
    /*
     This function populates the two anime arrays such that all anime in those lists are watched on a selected date
     parameters: date that is selected
     returns: none
     */
    private func populateDateArrays(_ date: Date) -> Double {
        var count = 0.0
        
        // iterate through watching list
        for anime in HomeViewController.currentlyWatchingAnimeTemp {
            let startDateComparator = Calendar.current.compare(date, to: anime.startDate!, toGranularity: .day)
            let endDateComparator = Calendar.current.compare(date, to: anime.endDate!, toGranularity: .day)
            // if anime is watched on the date, add it
            if (startDateComparator == .orderedDescending || startDateComparator == .orderedSame) && (endDateComparator == .orderedAscending || endDateComparator == .orderedSame) {
                var episodesWatchedOnNormalDays: Int = 0
                if anime.numberOfLastDays == 0 {
                    let durationOfNormalDays = Calendar.current.dateComponents([.day], from: anime.startDate!, to: anime.endDate!).day!
                    episodesWatchedOnNormalDays = durationOfNormalDays * Int(anime.episodesPerDay)
                }
                if endDateComparator == .orderedSame && anime.numberOfLastDays == 0 {
                    count += Double(Int(anime.episodes) - episodesWatchedOnNormalDays) * Double(anime.episodeLength)
                }
                else if CalendarViewController.checkIfInLastDays(anime, date) {
                    count += Double(anime.episodesPerDay + 1) * Double(anime.episodeLength)
                }
                else {
                    count += Double(anime.episodesPerDay) * Double(anime.episodeLength)
                }
            }
        }
        
        // iterate through completed list
        for anime in HomeViewController.completedAnimeTemp {
            let startDateComparator = Calendar.current.compare(date, to: anime.startDate!, toGranularity: .day)
            let endDateComparator = Calendar.current.compare(date, to: anime.endDate!, toGranularity: .day)
            // if anime was watched on the date, add it
            if (startDateComparator == .orderedDescending || startDateComparator == .orderedSame) && (endDateComparator == .orderedAscending || endDateComparator == .orderedSame) {
                var episodesWatchedOnNormalDays: Int = 0
                if anime.numberOfLastDays == 0 {
                    let durationOfNormalDays = Calendar.current.dateComponents([.day], from: anime.startDate!, to: anime.endDate!).day!
                    episodesWatchedOnNormalDays = durationOfNormalDays * Int(anime.episodesPerDay)
                }
                if endDateComparator == .orderedSame && anime.numberOfLastDays == 0 {
                    count += Double(Int(anime.episodes) - episodesWatchedOnNormalDays)
                }
                else if CalendarViewController.checkIfInLastDays(anime, date) {
                    count += Double(anime.episodesPerDay + 1) * Double(anime.episodeLength)
                }
                else {
                    count += Double(anime.episodesPerDay) * Double(anime.episodeLength)
                }
            }
        }
        return count
    }
    
}

extension AnalysisViewController: UITableViewDelegate{
    
}

extension AnalysisViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return columnNames.capacity
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = columnNames[indexPath.row]
        cell.detailTextLabel?.text = columnAnswers[indexPath.row]
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    
}

extension AnalysisViewController: ChartViewDelegate {
    
}

//extension AnalysisViewController: IAxisValueFormatter {
//    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
//        return String(value)
//    }
//}
