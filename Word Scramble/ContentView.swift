//
//  ContentView.swift
//  Word Scramble
//
//  Created by phoenix Dai on 2020/9/28.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTittle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    var body: some View {
        
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord) // onCommit 可以让输入和闭包连起来
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none) // 不会自动大写
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle") // 字符长度
                    Text($0)
                }
            }
            .navigationBarTitle(rootWord)
            .onAppear(perform: startGame) // 视图出现的时候调用startGame
            .navigationBarItems(leading:
                Button("Start") {
                startGame()
            })
        }
        .alert(isPresented: $showingError) {
            Alert(title: Text(errorTittle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) // 小写答案
        
        guard answer.count > 0 else {
            return
        }
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up.")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            return
        }
       
        
        usedWords.insert(answer, at: 0)
        newWord = "" // 更新newWord
    }
    
//MARK:- 开始游戏function
    func startGame() {
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {// Find the URL
            
            if let startWords = try? String(contentsOf: startWordsURL) {// Load the start.txt into a string
               
                let allWords = startWords.components(separatedBy: "\n")// separate the string and store in an Array
              
                rootWord = allWords.randomElement() ?? "silkworm" // 随机调取一个
                
                return
            }
            
        }
        
        fatalError("Could not load start.txt from bundle.") // return false
    }
    
    // our last method will make an instance of UITextChecker, which is responsible for scanning strings for misspelled words. We’ll then create an NSRange to scan the entire length of our string, then call rangeOfMisspelledWord() on our text checker so that it looks for wrong words. When that finishes we’ll get back another NSRange telling us where the misspelled word was found, but if the word was OK the location for that range will be the special value NSNotFound.
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    // 是否使用过该单词
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    //  if we create a variable copy of the root word, we can then loop over each letter of the user’s input word to see if that letter exists in our copy. If it does, we remove it from the copy (so it can’t be used twice), then continue. If we make it to the end of the user’s word successfully then the word is good, otherwise there’s a mistake and we return false.
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    
    func wordError(title: String, message: String) {
        errorTittle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
