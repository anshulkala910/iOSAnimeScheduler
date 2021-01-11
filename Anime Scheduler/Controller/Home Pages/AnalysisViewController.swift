//
//  AnalysisViewController.swift
//  Anime Scheduler
//
//  Created by Anshul Kala on 5/12/20.
//  Copyright © 2020 Anshul Kala. All rights reserved.
//

import UIKit
import Charts

// public class to format x-axis values
public class BarChartFormatter: NSObject, IAxisValueFormatter {
    
    var values = [String]()
    
    /*
     This function returns the string of the x-axis value
     parameters: value and axis
     returns: String
     */
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return values[Int(value)]
    }
    
    /*
     This function sets the global variable so that it contains data
     parameters: String list
     returns: void
     */
    public func setValues(values: [String])
    {
        self.values = values
    }
    
    
}

class AnalysisViewController: UIViewController {
    
    @IBOutlet weak var analysisTableView: UITableView!
    static var shouldCountHoursSpent = true
    @IBOutlet weak var fakeLabel: UILabel! // this label is used to position the chart correctly
    
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
        
        fakeLabel.isHidden = true // hide the label that is only required to position the chart correctly
        
        // if data should be counted again, populate data
        if AnalysisViewController.shouldCountHoursSpent == true {
            columnAnswers[0] = String(HomeViewController.completedAnimeTemp.count)
            columnAnswers[1] = String(HomeViewController.currentlyWatchingAnimeTemp.count) // MARK: TODO: This will consider anime that are to be started in the future
            
            columnAnswers[2] = getHoursSpent()
            fillChartData()
            self.analysisTableView.reloadData()
        }
        AnalysisViewController.shouldCountHoursSpent = false
        
        setChart(dataPoints: days, values: hoursForDays)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        barChart.frame = CGRect(x: fakeLabel.frame.origin.x, y: fakeLabel.frame.origin.y, width: fakeLabel.frame.width, height: fakeLabel.frame.height)
        view.addSubview(barChart)
    }
    
    /*
     This function sets the chart data and configures the chart
     parameters: dataPoints contains the x-values and values contains the y-values
     returns: void
     */
    func setChart(dataPoints: [String], values: [Double]) {
        // get formatter so x-axis can be formatted nicely
        let formatter = BarChartFormatter()
        formatter.setValues(values: dataPoints)

        var dataEntries: [BarChartDataEntry] = []

        // iterate throguh list and add data to dataEntries
        for i in 0..<dataPoints.count
        {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries) // create BarChartDataSet object

        let chartData = BarChartData(dataSet: chartDataSet) // create BarChartData object
        
        // configures x-axis
        let xAxis = barChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.labelCount = 7 // should have 7 days
        xAxis.axisMaxLabels = 7 // should have 7 days
        xAxis.valueFormatter = formatter // set the formatter so that data is shown correclty
        xAxis.drawGridLinesEnabled = false // disable vertical grid lines
        xAxis.drawLabelsEnabled = true // enable labelling for x-axis
        
        // configures y-axis or left axis
        let leftAxis = barChart.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0 // should start at 0
        leftAxis.drawGridLinesEnabled = false // disable horizontal grid lines
        
        barChart.drawGridBackgroundEnabled = false // disables grid
        barChart.dragEnabled = false // disable drag
        barChart.chartDescription?.enabled = false // diasble chart title
        barChart.legend.enabled = false // disable chart legend
        barChart.rightAxis.enabled = false // disable right axis
        barChart.doubleTapToZoomEnabled = false // disable zoom
        barChart.dragXEnabled = false // disable x-axis drag
        barChart.dragYEnabled = false // disable y-axis drag
        barChart.pinchZoomEnabled = false // disable pinch zoom
        barChart.scaleXEnabled = false // disable x-axis scaling
        barChart.scaleYEnabled = false // disable y-axis scaling
        
        barChart.data = chartData // set bar chart data as data created
    }
    
    /*
     this function fills in the global lists with data to use for the bar chart
     parameters: none
     returns: void
     */
    func fillChartData() {
        let currentDate = Date()
        let currentDay = getDateComponent(date: currentDate, .day)
        // set today's data manually
        days[6] = String(currentDay)
        hoursForDays[6] = populateDateArrays(currentDate)
        
        // get rest of data
        for range in 1...6 {
            let newDate = Calendar.current.date(byAdding: .day, value: 0 - Int(range), to: currentDate)
            days[6-range] = String(getDateComponent(date: newDate ?? currentDate, .day))
            hoursForDays[6-range] = populateDateArrays(newDate ?? currentDate)
        }
    }
    
    /*
     this function returns the total amount of time spent on watching anime
     parameters: none
     returns: String that represents time spend
     */
    func getHoursSpent() -> String {
        var minutesSpent = 0
        
        // count all minutes from completed anime
        for anime in HomeViewController.completedAnimeTemp {
            minutesSpent += Int(anime.episodes)*Int(anime.episodeLength)
        }
        
        // count all minutes from currently watching anime
        for anime in HomeViewController.currentlyWatchingAnimeTemp {
            minutesSpent += Int(anime.episodesFinished)*Int(anime.episodeLength)
        }
        
        // convert to string
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
     This function counts the minute spent for a StoredAnime object
     parameters: anime and date
     returns: Double that represents minutes spent
     */
    func countMinutesSpentOnAnime(anime: StoredAnime, date: Date) -> Double {
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
                return Double(Int(anime.episodes) - episodesWatchedOnNormalDays) * Double(anime.episodeLength)
            }
            else if CalendarViewController.checkIfInLastDays(anime, date) {
                return Double(anime.episodesPerDay + 1) * Double(anime.episodeLength)
            }
            else {
                return Double(anime.episodesPerDay) * Double(anime.episodeLength)
            }
        }
        return 0.0
    }
    
    /*
     This function counts the minute spent for a CompletedAnime object
     parameters: anime and date
     returns: Double that represents minutes spent
     */
    func countMinutesSpentOnAnime(anime: CompletedAnime, date: Date) -> Double {
        let currentDate = HomeViewController.getDateWithoutTime(date: date)
        for exceptionDay in anime.exceptionDays as! Set<ExceptionDay>{
            if exceptionDay.date == currentDate {
                return Double(exceptionDay.episodesWatched) * Double(anime.episodeLength)
            }
        }
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
                return Double(Int(anime.episodes) - episodesWatchedOnNormalDays) * Double(anime.episodeLength)
            }
            else if CalendarViewController.checkIfInLastDays(anime, date) {
                return Double(anime.episodesPerDay + 1) * Double(anime.episodeLength)
            }
            else {
                return Double(anime.episodesPerDay) * Double(anime.episodeLength)
            }
        }
        return 0.0
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
            count += countMinutesSpentOnAnime(anime: anime, date: date)
        }
        
        // iterate through completed list
        for anime in HomeViewController.completedAnimeTemp {
            count += countMinutesSpentOnAnime(anime: anime, date: date)
        }
        return count
    }
    
}

extension AnalysisViewController: UITableViewDelegate{
    
}

extension AnalysisViewController: UITableViewDataSource{
    
    /*
     This function determines the number of rows to be present in the table
     parameters: table and section number
     returns: int
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return columnNames.capacity
    }
    
    /*
     This function declares a cell to reused over and over and also fills in the cell data
     parameters: table and index path
     returns: cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = columnNames[indexPath.row]
        cell.detailTextLabel?.text = columnAnswers[indexPath.row]
        cell.layoutMargins = UIEdgeInsets.zero
        
        cell.textLabel?.sizeToFit()
        cell.detailTextLabel?.sizeToFit()
        return cell
    }
    
    
}

extension AnalysisViewController: ChartViewDelegate {
    
}
