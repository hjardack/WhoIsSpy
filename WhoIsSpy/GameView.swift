import SwiftUI

struct GameView: View {
    let roles: [PlayerRole]
    let secretWord: String
    
    @State private var currentIndex: Int = 0
    @State private var hasRevealed: Bool = false
    @State private var gameFinished: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Player \(currentIndex + 1) of \(roles.count)")
                .font(.headline)
            
            if !hasRevealed {
                Text("Pass the phone to Player \(currentIndex + 1).")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("Tap to reveal your role") {
                    withAnimation {
                        hasRevealed = true
                    }
                }
                .buttonStyle(.borderedProminent)
            } else {
                roleView
                
                Button("Hide and pass to next player") {
                    advance()
                }
                .buttonStyle(.bordered)
                .padding(.top)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Reveal roles")
        .alert("All roles assigned", isPresented: $gameFinished) {
            Button("New game") {
                dismiss()
            }
            Button("Stay here", role: .cancel) { }
        } message: {
            Text("Everyone has seen their role. Start the discussion in real life.")
        }
    }
    
    @ViewBuilder
    private var roleView: some View {
        let role = roles[currentIndex]
        
        switch role {
        case .spy:
            Text("You are the SPY")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 4)
            Text("Try to guess the secret word without revealing yourself.")
                .multilineTextAlignment(.center)
                .font(.body)
        case .civilian:
            Text(secretWord)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 4)
            Text("This is the secret word. Blend in and find the spy.")
                .multilineTextAlignment(.center)
                .font(.body)
        }
    }
    
    private func advance() {
        if currentIndex < roles.count - 1 {
            currentIndex += 1
            hasRevealed = false
        } else {
            gameFinished = true
        }
    }
}
//
//  GameView.swift
//  WhoIsSpy
//
//  Created by Development on 11/21/25.
//

