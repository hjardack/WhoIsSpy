import SwiftUI

// MARK: - Models
enum PlayerRole {
    case spy
    case civilian
}

struct GameConfig {
    let roles: [PlayerRole]
    let secretWord: String
}

// MARK: - ContentView (Setup Screen)

struct ContentView: View {
    @State private var numberOfPlayers: Int = 5
    @State private var numberOfSpies: Int = 1
    @State private var useRandomWord: Bool = true
    @State private var customWord: String = ""

    @State private var gameConfig: GameConfig? = nil
    @State private var isShowingGame: Bool = false

    // Basic word list for random secret words
    private let wordList: [String] = [
        "Pizza", "Airport", "Beach", "Library", "Hospital",
        "Football", "Concert", "Museum", "Restaurant", "Zoo",
        "Camping", "Cinema", "Supermarket", "Office", "Gym",
        "School", "Bakery", "Hotel", "Train", "Park"
    ]

    private var trimmedCustomWord: String {
        customWord.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var maxSpies: Int {
        // At least 1 spy and at most 3 or players-1, whichever is smaller
        max(1, min(3, numberOfPlayers - 1))
    }

    private var canStartGame: Bool {
        numberOfPlayers >= 3 &&
        numberOfSpies >= 1 &&
        numberOfSpies < numberOfPlayers &&
        (useRandomWord || !trimmedCustomWord.isEmpty)
    }

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Players") {
                        Stepper(value: $numberOfPlayers, in: 3...20) {
                            Text("Number of players: \(numberOfPlayers)")
                        }

                        Stepper(value: $numberOfSpies, in: 1...maxSpies) {
                            Text("Number of spies: \(numberOfSpies)")
                        }
                        // iOS 17+ onChange signature (2-parameter closure)
                        .onChange(of: numberOfPlayers) { oldValue, newValue in
                            if numberOfSpies >= newValue {
                                numberOfSpies = max(1, newValue - 1)
                            }
                        }
                    }

                    Section("Secret word") {
                        Toggle("Use random word", isOn: $useRandomWord.animation())

                        if !useRandomWord {
                            TextField("Enter secret word", text: $customWord)
                                .textInputAutocapitalization(.words)
                        } else {
                            Text("A random word will be chosen each game.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Section("How to play") {
                        Text("""
1. Set the number of players and spies.
2. Start the game and pass the phone around.
3. Each player taps to see their role.
4. Spies see “You are the SPY”.
5. Others see the secret word.
6. After everyone has seen their role, discuss and vote in real life.
""")
                        .font(.footnote)
                    }
                }

                Button(action: startGame) {
                    Text("Start game")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .disabled(!canStartGame)
            }
            .navigationTitle("Who is the Spy?")
            .navigationDestination(isPresented: $isShowingGame) {
                if let config = gameConfig {
                    GameView(roles: config.roles, secretWord: config.secretWord)
                } else {
                    // Should never happen, but ensures a View is always returned.
                    Text("Missing game config")
                }
            }
        }
    }

    // MARK: - Game setup logic

    private func startGame() {
        guard canStartGame else { return }

        let word: String
        if useRandomWord {
            word = wordList.randomElement() ?? "Sun"
        } else {
            word = trimmedCustomWord
        }

        let roles = generateRoles(
            playerCount: numberOfPlayers,
            spyCount: numberOfSpies
        )

        gameConfig = GameConfig(roles: roles, secretWord: word)
        isShowingGame = true
    }

    private func generateRoles(playerCount: Int, spyCount: Int) -> [PlayerRole] {
        var roles = Array(repeating: PlayerRole.civilian, count: playerCount)

        var availableIndices = Array(0..<playerCount)
        for _ in 0..<spyCount {
            if availableIndices.isEmpty { break }
            let randomIndex = Int.random(in: 0..<availableIndices.count)
            let chosen = availableIndices[randomIndex]
            roles[chosen] = .spy
            availableIndices.remove(at: randomIndex)
        }

        return roles
    }
}

