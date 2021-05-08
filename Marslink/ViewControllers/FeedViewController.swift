/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import IGListKit


class FeedViewController: UIViewController {
    
    let loader = JournalEntryLoader()
    
    let wxScanner = WxScanner()

    let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero,
                                    collectionViewLayout: UICollectionViewFlowLayout())
        view.backgroundColor = .black
        return view
    }()
    
    let pathfinder = Pathfinder()
    
    /// updater: an object conforming to ListUpdatingDelegate, which handles row and section updates. ListAdapterUpdater is a default implementation that's suitable for your usage.
    /// viewController: is a UIViewController the houses the adapter. IGListKit uses this view controller later for navigating to other view controllers.
    /// workingRangeSize is the size of the working range, which allows you to prepare content for sections just outside of the visible frame.
    lazy var adapter: ListAdapter = {
        return ListAdapter(
            updater: ListAdapterUpdater(),
            viewController: self,
            workingRangeSize: 0)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        loader.loadLatest()
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        pathfinder.delegate = self
        pathfinder.connect()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}

extension FeedViewController: ListAdapterDataSource {
    
    /// returns an array of data objects that should show up in the collection view. You provide loader.entries here as it contains the journal entries.
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        
//        var items: [ListDiffable] = pathfinder.messages
//        items += loader.entries as [ListDiffable]
//        return items
        var items: [ListDiffable] = [wxScanner.currentWeather]
        items += loader.entries as [ListDiffable]
        items += pathfinder.messages as [ListDiffable]
        
        return items.sorted { (left: Any, right: Any) -> Bool in
            guard let
            left = left as? DateSortable,
                  let right = right as? DateSortable
            else {
                return false
            }
            return left.date > right.date
        }
    }
    
    
    /// must return a new instance of a section controller.
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is Message {
            return MessageSectionController()
        }
        else if object is JournalEntry {
            return JournalSectionController()
        }
        else {
            return WeatherSectionController()
        }
    }
    /// returns a view to display when the list is empty. NASA is in a bit of a time crunch, so they didn't budget for this feature.
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    
}

extension FeedViewController: PathfinderDelegate {
    func pathfinderDidUpdateMessages(pathfinder: Pathfinder) {
        adapter.performUpdates(animated: true, completion: nil)
    }
}
