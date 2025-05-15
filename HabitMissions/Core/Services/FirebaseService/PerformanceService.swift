//
//  PerformanceService.swift
//  HabitMissions
//
//  Created by David Springean on 15.05.25.
//


import FirebasePerformance


class PerformanceService {
    static let shared = PerformanceService()
    
    
    // Track app launch time
    func trackAppLaunch() {
        let trace = Performance.startTrace(name: "app_launch")
        // Call this method when app launch completes
        trace?.stop()
    }
    
    // Track OpenAI API response time
    func trackOpenAIResponse(operation: String) -> Trace {
        let trace = Performance.startTrace(name: "openai_response")
        trace?.setValue(operation, forAttribute: "operation")
        return trace!
    }
    
    // Track screen load time
    func trackScreenLoad(screenName: String) -> Trace {
        let trace = Performance.startTrace(name: "screen_load")
        trace?.setValue(screenName, forAttribute: "screen_name")
        return trace!
    }
}
