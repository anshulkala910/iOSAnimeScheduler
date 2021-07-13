# iOSAnimeScheduler

## Table of Contents
1. [Introduction](#introduction)
2. [Home Page](#home-page)
    1. [Adding a New Anime](#adding-a-new-anime)
    2. [Updating an Anime](#updating-an-anime)
4. [Calendar Page](#calendar-page)
5. [Statistics Page](#statistics-page)


## Introduction

Anime Scheduler is an iOS app that schedules users' anime (_Japanese animated shows_) according to their preference: users can either provide a specific date range or the number of episodes to be watched a day. The app utilizes a [REST API](https://jikan.moe) to obtain data of various anime, which is then displayed to users. Moreover, the anime scheduler app provides a calendar interface the user can take advantage of to view the number of episodes to be watched on a specific day. Lastly, the app displays statistics in order for the users to have a better understanding on how much time they're spending on watching anime.


## Home Page

The home page displays the anime users are watching and have already completed, separated by two TableViews. Along with the anime currently being watched, the app displays the number of episodes per day users should watch for the corresponding anime. On the top right corner, there is a "+" button that users can use to add an anime to their list. For more details on adding an anime, check out [Adding a New Anime](#adding-a-new-anime)

If users want to check whether they are on track of finishing the anime on time (as per their goal), they can tap on the anime to check the details. But, what if users are not on track and have watched more or less episodes than they should have? Check out [Updating an Anime](#updating-an-anime)

Here is a screenshot to show what the home page looks like:
<p align="center">
    <img src = "https://user-images.githubusercontent.com/62824259/125513400-b77ebec0-b09e-4afe-8b92-5382c24fd6d5.png" height = "700" width = "350"/>
</p>

[comment]: <> (Maybe show use of https://www.donnywals.com/efficiently-loading-images-in-table-views-and-collection-views/ in app)

###### Techniques Used
1. CoreData: CoreData is a persistence framework that saves application data onto the user's device. In this app, the list of currently watching and completed anime was stored onto the user's device using CoreData by creating object entities of anime that store necessary details, such as start/end date, number of episodes to be watched a day, etc. 
2. Asynchronously loading and caching images: 

#### Adding a New Anime

<p align="center">
<img src = "https://user-images.githubusercontent.com/62824259/125517813-0a05ff7e-dc34-4097-b90f-b2428c0db0ef.gif" height = "700" width = "350" />
</p>

###### Techniques Used

#### Updating an Anime

<p align="center">
<img src = "https://user-images.githubusercontent.com/62824259/125517842-b2f56776-386a-4256-8754-ac4a5d92e07e.gif" height = "700" width = "350" />
</p>

###### Techniques Used


## Calendar Page

<p align="center">
<img src = "https://user-images.githubusercontent.com/62824259/125513446-3a4ff616-09bf-4e84-ae65-5ebc8addc4a5.png" height = "700" width = "350" />
</p>

###### Techniques Used

## Statistics Page

<p align="center">
<img src = "https://user-images.githubusercontent.com/62824259/125513512-0c13735f-50fa-41bb-b6f3-2e4c6546be29.png" height = "700" width = "350" />
</p>

###### Techniques Used

