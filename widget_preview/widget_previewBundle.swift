//
//  widget_previewBundle.swift
//  widget_preview
//
//  Created by Aholt on 2025/9/1.
//

import WidgetKit
import SwiftUI

@main
struct widget_previewBundle: WidgetBundle {
    var body: some Widget {
        widget_preview()
        widget_previewLiveActivity()
        FreshCalendarWidget()
    }
}
