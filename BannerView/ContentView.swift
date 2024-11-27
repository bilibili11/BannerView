//
//  ContentView.swift
//  BannerView
//
//  Created by apple on 2024/11/27.
//

import SwiftUI
class BannerItemModel: ObservableObject,Identifiable,Equatable,BannerItemDelegate {
    
    static func == (lhs: BannerItemModel, rhs: BannerItemModel) -> Bool {
        lhs.id == rhs.id
    }
    
    
    var id = UUID().uuidString
    let color:Color
    var index:Int
    @Published var offset:CGFloat = 0
    init(color: Color,index:Int) {
        self.color = color
        self.index = index
    }
}
struct BannerItemContentView :View {
    @ObservedObject var itemModel: BannerItemModel
    
    typealias ItemType = BannerItemModel
    
    var index: Int
    
    var body: some View{
        ZStack {
            itemModel.color
            Text("index = \(itemModel.index)")
        }
    }
}
struct ContentView: View {
    var body: some View {
        var models:[BannerItemModel] = []
        for index in 0..<8{
            models.append(.init(color: .randomColor, index: index))
        }
        return BannerView(source: models) { item, index in
            BannerItemContentView(itemModel: item, index: index)
        }
    }
}

#Preview {
    ContentView()
}
