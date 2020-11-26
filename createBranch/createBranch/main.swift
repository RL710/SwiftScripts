//
//  main.swift
//  createBranch
//
//  Created by Rene Lv on 20.11.20.
//

import Foundation

// MARK: - Helper

@discardableResult func shell(_ command: String) -> (String?, Int32) {
    let task = Process()

    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    task.waitUntilExit()
    return (output, task.terminationStatus)
}

@discardableResult
func shell(_ commands: [String]) -> [(String?, Int32)] {
    var outputs = [(String?, Int32)]()
    for command in commands {
        outputs.append(shell(command))
    }
    return outputs
}

// MARK: - Main
print(CommandLine.arguments)
let howToMessage = "Usage: \n\nCreate a branch (release (r), feature (f), bugfix (b)). \n\nExample input: createBranch f \"ProjectNumber007 the answer to everything feature\"\nThe branch will look like: \nfeature/ProjectNumber007-the-answer-to-everything-feature"

if CommandLine.arguments.count == 3 {
    
    let branchType = getBranchType(CommandLine.arguments[1])
    let branchName = resolveBranchName(CommandLine.arguments[2])
    
    print("Create branch: \(branchType)/\(branchName)?")
    if readLine() == "y" {
        let outputs = shell([
            "git checkout -b \(branchType)/\(branchName))",
            "git  push --set-upstream origin \(branchType)/\(branchName)"
        ])
        var success = true
        for (_, status) in outputs {
            if status != 0 {
                success = false
            }
        }
        if success {
            print("✅  Created and pushed branch.")
        }
        else {
            print("🔥 Failed to create and push branch")
        }
        
    }
    
} else {
    print(howToMessage)
}


func getBranchType(_ arg: String) -> String {
    
    for argument in CommandLine.arguments {
        
        switch argument {
        case "release", "r", "-r":
            return "release"

        case "feature", "f", "-f":
            return "feature"
        
        case "bugfix", "b", "-b":
            return "bugfix"
            
        default:
            break
        }
    }
    return ""
}

func resolveBranchName(_ arg: String) -> String {
    let nonAlphaNumeric = CharacterSet.alphanumerics.inverted
    return arg.folding(options: .diacriticInsensitive, locale: .current).components(separatedBy: nonAlphaNumeric).joined(separator: "-")
}
