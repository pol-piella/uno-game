//
//  ContentView.swift
//  Uno
//
//  Created by Pol Piella Abadia on 02/06/2022.
//

import SwiftUI

struct InnerOval: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: .init(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(to: .init(x: rect.maxX, y: rect.minY), control: .init(x: rect.minY, y: rect.minX))
        path.move(to: .init(x: rect.maxX, y: rect.minY))
        path.addQuadCurve(to: .init(x: rect.minX, y: rect.maxY), control: .init(x: rect.maxX, y: rect.maxY))
        
        return path
    }
}

struct LargeText: View {
    let number: Int
    let foreground: Color
    let background: Color
    let font: Font
    
    var body: some View {
        ZStack {
            Text(String(number))
                .fontWeight(.bold)
                .font(font)
                .offset(x: -1, y: 2)
                .foregroundColor(background)
            
            Text(String(number))
                .fontWeight(.bold)
                .font(font)
                .foregroundColor(foreground)
        }
    }
}

struct Card: View {
    let number: Int
    let color: Color
    let isPlayable: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            LargeText(number: number, foreground: .white, background: .black, font: .largeTitle)
                .padding()
            
            ZStack {
                Ellipse()
                    .rotation(.degrees(-40))
                    .stroke(.white, lineWidth: 10)
                LargeText(number: number, foreground: .white, background: .black, font: .system(size: 95))
            }
            
            HStack {
                Spacer()
                LargeText(number: number, foreground: .white, background: .black, font: .largeTitle)
                    .padding()
            }
        }
        .background(color)
        .overlay(
             RoundedRectangle(cornerRadius: 10)
                 .stroke(Color.white, lineWidth: 8)
         )
        .shadow(radius: 2)
    }
}

struct CardModel: Identifiable {
    let id = UUID()
    
    let number: Int
    let color: Color
    let offset: CGPoint
}

struct ContentView: View {
    @State var centerCards: [CardModel] = [.init(number: 2, color: .red, offset: .zero)]
    @State var hand: [CardModel] = [
        .init(number: 2, color: .blue, offset: .zero),
        .init(number: 2, color: .yellow, offset: .zero),
        .init(number: 2, color: .red, offset: .zero),
        .init(number: 2, color: .green, offset: .zero),
        .init(number: 2, color: .blue, offset: .zero),
        .init(number: 2, color: .yellow, offset: .zero),
        .init(number: 2, color: .blue, offset: .zero),
        .init(number: 2, color: .blue, offset: .zero),
    ]
    @State var dragAmount = CGSize.zero
    @State var dropArea = CGRect.zero
    @State var draggedFrame = CGRect.zero
    @State var animatingIndex: UUID?
    


    var body: some View {
        VStack {
            Text("Wait, it's Chloe's turn...")
            
            Spacer()
            ZStack {
                ForEach(centerCards) { card in
                    Card(number: card.number, color: card.color)
                        .offset(x: card.offset.x, y: card.offset.y)
                }
            }
            .frame(width: 190, height: 300)
            .overlay(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            dropArea = geo.frame(in: .global)
                        }
                }
            )

            
            Spacer()
            
            ZStack {
                ForEach(Array(zip(hand.indices, hand)), id: \.0) { index, card in
                    Card(number: card.number, color: card.color)
                        .gesture(
                            DragGesture(coordinateSpace: .global)
                                .onChanged { value in
                                    self.animatingIndex = card.id
                                    self.dragAmount = .init(width: value.translation.width, height: value.translation.height)
                                }
                                .onEnded { point in
                                    if dropArea.contains(point.location) {
                                        hand.removeAll { $0.id == card.id }
                                        let newCard = CardModel(
                                            number: card.number,
                                            color: card.color,
                                            offset: .init(x: .random(in: -15...15), y: .random(in: -15...15))
                                        )
                                        centerCards.append(newCard)
                                    }
                                    self.animatingIndex = nil
                                    self.dragAmount = .zero
                                }
                        )
                        .offset(animatingIndex == card.id ? dragAmount : .zero)
//                        .if(animatingIndex == card.id, transform: { view in
//                            view.offset(dragAmount)
//                        })
                        .frame(width: 190, height: 300)
                }
            }
        }
        .padding()
    }
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
