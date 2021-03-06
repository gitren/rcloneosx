//
//  This object stays in memory runtime and holds key data and operations on Schedules.
//  The obect is the model for the Schedules but also acts as Controller when
//  the ViewControllers reads or updates data.
//
//  Created by Thomas Evensen on 09/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class Schedules: ScheduleWriteLoggData {

    var profile: String?

    // Return reference to Schedule data
    // self.Schedule is privat data
    func getSchedule() -> [ConfigurationSchedule] {
        return self.schedules ?? []
    }

    /// Function deletes all Schedules by hiddenID. Invoked when Configurations are
    /// deleted. When a Configuration are deleted all tasks connected to
    /// Configuration has to  be deleted.
    /// - parameter hiddenID : hiddenID for task
    func deletescheduleonetask(hiddenID: Int) {
        var delete: Bool = false
        for i in 0 ..< self.schedules!.count where self.schedules![i].hiddenID == hiddenID {
            // Mark Schedules for delete
            // Cannot delete in memory, index out of bound is result
            self.schedules![i].delete = true
            delete = true
        }
        if delete {
            self.storageapi!.saveScheduleFromMemory()
            // Send message about refresh tableView
            self.reloadtable(vcontroller: .vctabmain)
        }
    }

    // Test if Schedule record in memory is set to delete or not
    private func delete(dict: NSDictionary) {
        loop :  for i in 0 ..< self.schedules!.count {
            if dict.value(forKey: "hiddenID") as? Int == self.schedules![i].hiddenID {
                if dict.value(forKey: "dateStop") as? String == self.schedules![i].dateStop ||
                    self.schedules![i].dateStop == nil &&
                    dict.value(forKey: "schedule") as? String == self.schedules![i].schedule &&
                    dict.value(forKey: "dateStart") as? String == self.schedules![i].dateStart {
                    self.schedules![i].delete = true
                    break
                }
            }
        }
    }

    // Function for reading all jobs for schedule and all history of past executions.
    // Schedules are stored in self.schedules. Schedules are sorted after hiddenID.
    private func readschedules() {
        var store: [ConfigurationSchedule]? = self.storageapi!.getScheduleandhistory(nolog: false)
        guard store != nil else { return }
        var data = [ConfigurationSchedule]()
        for i in 0 ..< store!.count {
            data.append(store![i])
        }
        // Sorting schedule after hiddenID
        data.sort { (schedule1, schedule2) -> Bool in
            if schedule1.hiddenID > schedule2.hiddenID {
                return false
            } else {
                return true
            }
        }
        // Setting self.Schedule as data
        self.schedules = data
    }

    init(profile: String?) {
        super.init()
        self.profile = profile
        self.storageapi = PersistentStorageAPI(profile: self.profile)
        self.readschedules()
    }
}
