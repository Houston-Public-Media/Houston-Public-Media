//
//  LaunchScreenView.swift
//  Houston Public Media
//
//  Created by Jared Counts on 11/1/24.
//


import SwiftUI

enum LaunchScreenStep {
	case firstStep
	case secondStep
	case finished
}

final class LaunchScreenStateManager: ObservableObject {
	@MainActor @Published private(set) var state: LaunchScreenStep = .firstStep
	@MainActor func dismiss() {
		Task {
			state = .secondStep
			try? await Task.sleep(for: Duration.seconds(1))
			self.state = .finished
		}
	}
}

struct LaunchScreenView: View {
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager // Mark 1

    @State private var firstAnimation = false  // Mark 2
    @State private var secondAnimation = false // Mark 2
    @State private var startFadeoutAnimation = false // Mark 2
    
    @ViewBuilder
    private var image: some View {  // Mark 3
		Image(.hpmLogo)
            .resizable()
            .scaledToFit()
            .frame(width: 250, height: 250)
            .scaleEffect(firstAnimation ? 1 : 0) // Mark 4
            .scaleEffect(secondAnimation ? 0 : 1) // Mark 4
            .offset(y: secondAnimation ? 400 : 0) // Mark 4
    }
    
    @ViewBuilder
    private var backgroundColor: some View {  // Mark 3
		Color(hue: 0.972, saturation: 0.92, brightness: 0.78, opacity: 1.0).ignoresSafeArea()
    }
    
    private let animationTimer = Timer // Mark 5
        .publish(every: 0.5, on: .current, in: .common)
        .autoconnect()
    
    var body: some View {
        ZStack {
            backgroundColor  // Mark 3
            image  // Mark 3
        }.onReceive(animationTimer) { timerValue in
            updateAnimation()  // Mark 5
        }.opacity(startFadeoutAnimation ? 0 : 1)
    }
    
    private func updateAnimation() { // Mark 5
        switch launchScreenState.state {  
        case .firstStep:
            withAnimation(.linear) {
				self.firstAnimation = true
            }
        case .secondStep:
            if secondAnimation == false {
                withAnimation(.linear) {
                    self.secondAnimation = true
                    startFadeoutAnimation = true
                }
            }
        case .finished: 
            // use this case to finish any work needed
            break
        }
    }
    
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
            .environmentObject(LaunchScreenStateManager())
    }
}
