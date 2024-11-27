//
//  BannerView.swift
//  AESMAcPlayer
//
//  Created by apple on 2024/11/27.
//

import SwiftUI
extension Color{
    init(hex: String,alpha: Double = 1) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#") // 跳过'#'字符
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0xFF00) >> 8) / 255.0
        let b = Double(rgbValue & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b,opacity: alpha)
    }
    static var randomColor:Color{
        let red = CGFloat(arc4random()%256)/255.0
        let green = CGFloat(arc4random()%256)/255.0
        let blue = CGFloat(arc4random()%256)/255.0
        return Color.init(red: red, green: green, blue: blue)
    }
}
protocol BannerItemDelegate:ObservableObject,Equatable {
    var index:Int{set get}
    var offset:CGFloat{set get}
    var id:String{set get}
}

class BannerViewModel<T:BannerItemDelegate>: ObservableObject {
    var allSource : [T]
    @Published var source : [T] = []
    init(allSource:[T]){
        self.allSource = allSource
        for item in allSource{
            source.append(item)
            if source.count == showCount{
                return
            }
        }
    }
    let showCount:Int = 3
    
    func checkIsTop(nowIndex:Int)->Bool{
        source.first?.index == nowIndex
    }
    func next(){
        
        if let last = source.last,
           let lastIndex = allSource.firstIndex(where: { model in
               model == last
           }){
            var appLastIndex =  lastIndex + 1
            if lastIndex == allSource.count - 1{
                appLastIndex = 0
            }
            source.removeFirst()
            source.append(allSource[appLastIndex])
        }
        
        
    }
}

struct BannerView<T: BannerItemDelegate, Content: View>: View {
    @StateObject var viewModel: BannerViewModel<T>
    let content: (T, Int) -> Content

    init(source: [T], @ViewBuilder content: @escaping (T, Int) -> Content) {
        self._viewModel = StateObject(wrappedValue: BannerViewModel(allSource: source))
        self.content = content
    }

    var body: some View {
        ZStack {
            ForEach(Array(viewModel.source.enumerated().reversed()), id: \.element.id) { index, model in
                BannerItemView(itemModel: model, index: index, checkIndexBlock: { idx in
                    viewModel.checkIsTop(nowIndex: idx)
                }, nextBlock: {
                    viewModel.next()
                }) {
                    content(model, index)
                }
            }
        }
    }
}

struct BannerItemView<ContentView: View, ItemModel: BannerItemDelegate>: View {
    @StateObject var itemModel: ItemModel
    var index: Int
    var checkIndexBlock: (Int) -> Bool
    var nextBlock: () -> Void
    var content: ContentView

    init(itemModel: ItemModel, index: Int, checkIndexBlock: @escaping (Int) -> Bool, nextBlock: @escaping () -> Void, @ViewBuilder content: () -> ContentView) {
        self._itemModel = StateObject(wrappedValue: itemModel)
        self.index = index
        self.checkIndexBlock = checkIndexBlock
        self.nextBlock = nextBlock
        self.content = content()
    }

    var body: some View {
        ZStack(content: {
            content
        })
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .frame(width: 300, height: 530)
        .scaleEffect(y: 1 - CGFloat(index) * 0.1, anchor: .center)
        .offset(x: CGFloat(index * 20) + itemModel.offset - 20, y: CGFloat(index * 3))
        .gesture(
            DragGesture(coordinateSpace: .local)
                .onChanged { value in
                    guard checkIndexBlock(itemModel.index) else {
                        return
                    }
                    itemModel.offset = value.translation.width
                }
                .onEnded { value in
                    if abs(itemModel.offset) > 30 {
                        withAnimation(.spring) {
                            itemModel.offset = 0
                            nextBlock()
                        }
                    } else {
                        itemModel.offset = 0
                    }
                }
        )
    }
}


struct BannerPreview:PreviewProvider{
    
    static var previews: some View{
        var models:[BannerItemModel] = []
        for index in 0..<8{
            models.append(.init(color: .randomColor, index: index))
        }
        return BannerView(source: models, content: { model , index in
            BannerItemContentView(itemModel: model, index: index)
        })
    }
}

