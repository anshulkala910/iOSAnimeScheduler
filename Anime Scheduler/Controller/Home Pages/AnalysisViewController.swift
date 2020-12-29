//
//  AnalysisViewController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/12/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit
import Charts

class AnalysisViewController: UIViewController {
    
    @IBOutlet weak var analysisTableView: UITableView!
    static var shouldCountHoursSpent = true
    @IBOutlet weak var fakeLabel: UILabel!
    
    let columnNames = ["Completed", "Currently Watching","Hours Spent"]
    var columnAnswers = ["0","0","0"]
    
    var barChart = BarChartView()
    
    var days = [1,2,3,4,5,6,7]
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
            self.analysisTableView.reloadData()
        }
        AnalysisViewController.shouldCountHoursSpent = false
        barChart.drawGridBackgroundEnabled = false
        barChart.dragEnabled = false
        let xAxis = barChart.xAxis
                xAxis.labelPosition = .bottom
                xAxis.labelFont = .systemFont(ofSize: 10)
                xAxis.granularity = 1
                xAxis.labelCount = 7
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
        barChart.legend.enabled = false
        fillChartData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        barChart.frame = CGRect(x: fakeLabel.frame.origin.x, y: fakeLabel.frame.origin.y, width: fakeLabel.frame.width, height: fakeLabel.frame.height)
        view.addSubview(barChart)
        var data = [BarChartDataEntry]()
        for x in 0...6 {
           // data.append(BarChartDataEntry(x: Double(x), y: Double(x)))
            data.append(BarChartDataEntry(x: Double(days[x]), y: hoursForDays[x]))
        }
        let set = BarChartDataSet(entries: data)
        let date = BarChartData(dataSet: set)
        barChart.data = date
    
    }
    
    func fillChartData() {
        let currentDate = Date()
        let currentDay = getDateComponent(date: currentDate, .day)
        days[6] = currentDay
        hoursForDays[6] = populateDateArrays(currentDate)
        for range in 1...6 {
            days[6-range] = currentDay - range
            hoursForDays[6-range] = populateDateArrays(Calendar.current.date(byAdding: .day, value: 0 - Int(range), to: currentDate) ?? currentDate)
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
                if CalendarViewController.checkIfInLastDays(anime, date) {
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
                if CalendarViewController.checkIfInLastDays(anime, date) {
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
