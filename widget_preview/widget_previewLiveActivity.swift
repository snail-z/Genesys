//
//  widget_previewLiveActivity.swift
//  widget_preview
//
//  Created by Aholt on 2025/9/1.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct widget_previewAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct widget_previewLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: widget_previewAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension widget_previewAttributes {
    fileprivate static var preview: widget_previewAttributes {
        widget_previewAttributes(name: "World")
    }
}

extension widget_previewAttributes.ContentState {
    fileprivate static var smiley: widget_previewAttributes.ContentState {
        widget_previewAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: widget_previewAttributes.ContentState {
         widget_previewAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: widget_previewAttributes.preview) {
   widget_previewLiveActivity()
} contentStates: {
    widget_previewAttributes.ContentState.smiley
    widget_previewAttributes.ContentState.starEyes
}
