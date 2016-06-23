//
//  SearchResultsTableViewController.swift
//  Timeline
//
//  Created by Sean Gilhuly on 6/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class SearchResultsTableViewController: UITableViewController {

    var resultsArray: [SearchableRecord] = []

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("resultCell", forIndexPath: indexPath) as? PostTableViewCell ?? PostTableViewCell()

        guard let result = resultsArray[indexPath.row] as? Post else { return UITableViewCell() }
        cell.updateWithPost(result)
        
        return cell
    }
    
    // MARK: - Table View Delegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        self.presentingViewController?.performSegueWithIdentifier("toPostDetailFromSearch", sender: cell)
    }
}