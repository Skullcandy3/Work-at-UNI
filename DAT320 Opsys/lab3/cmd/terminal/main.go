// Task 7: Simple Shell
//
// This task focuses on building a simple shell that accepts
// commands that run certain OS functions or programs. For OS
// functions refer to golang's built-in OS and ioutil packages.
//
// The shell should be implemented through a command line
// application; allowing the user to execute all the functions
// specified in the task. Info such as [path] are command arguments
//
// Important: The prompt of the shell should print the current directory.
// For example, something like this:
//   /Users/meling/Dropbox/work/opsys/2020/meling-stud-labs/lab3>
//
// We suggest using a space after the > symbol.
//
// Your program should be able to at least the following functions:
// 	- exit
// 		- exit the program
// 	- cd [path]
// 		- change directory to a specified path
// 	- ls
// 		- list items and files in the current path
// 	- mkdir [path]
// 		- create a directory with the specified path
// 	- rm [path]
// 		- remove a specified file or folder
// 	- create [path]
// 		- create a file with a specified name
// 	- cat [file]
// 		- show the contents of a specified file
// 			- any file, you can use the 'hello.txt' file to check if your
// 			  implementation works
// 	- help
// 		- show a list of available commands
//
// You may also implement any number of optional functions, here are some ideas:
// 	- help [command]
// 		- give additional info on a certain command
// 	- ls [path]
// 		- make ls allow for a specified path parameter
// 	- rm -r
// 		WARNING: Be aware of where you are when you try to execute this command
// 		- recursively remove a directory
// 			- meaning that if the directory contains files, remove
// 			  all the files within the directory first, then the
// 			  directory itself
// 	- calc [expression]
// 		- Simple calculator program that can calculate a given expression
// 			- example expressions could be + - * \ pow
// 	- ipconfig
// 		- show ip interfaces
// 	- history
// 		- show command history
// 		- Alternatively implement this together with pressing up on your
// 		  keypad to load the previous command
// 		- clrhistory to clear history
// 	- tail [n]
// 		- show last n lines of a file
// 	- head [n]
// 		- show first n lines of a file
// 	- writefile [text]
// 		- write specified text to a specified file
//
// 	Or, alternatively, implement your own functionality not specified as you please
//
// Additional notes:
// 	- If you want to use colors in your terminal program you can see the package
// 		"github.com/fatih/color"
//
// 	- Helper functions may lead to cleaner code
//

package main

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// Terminal struct will keep track of current directory
type Terminal struct {
	currentDir string
}

// Execute runs a given command
func (t *Terminal) Execute(input string) {
	// Split the input into command and arguments
	args := strings.Fields(input)
	if len(args) == 0 {
		return // nothing entered
	}
	command := args[0]

	switch command {
	case "exit":
		fmt.Println("Exiting terminal...")
		os.Exit(0)

	case "cd":
		if len(args) < 2 {
			fmt.Println("cd: missing path")
			return
		}
		path := args[1]
		// Join with currentDir to allow relative paths
		newPath := path
		if !filepath.IsAbs(path) {
			newPath = filepath.Join(t.currentDir, path)
		}
		err := os.Chdir(newPath)
		if err != nil {
			fmt.Println("cd error:", err)
			return
		}
		t.currentDir, _ = os.Getwd()

	case "ls":
		// If no argument given, list current directory
		target := t.currentDir
		if len(args) > 1 {
			target = args[1]
		}
		files, err := os.ReadDir(target)
		if err != nil {
			fmt.Println("ls error:", err)
			return
		}
		for _, f := range files {
			fmt.Println(f.Name())
		}

	case "mkdir":
		if len(args) < 2 {
			fmt.Println("mkdir: missing directory name")
			return
		}
		path := filepath.Join(t.currentDir, args[1])
		err := os.Mkdir(path, 0755)
		if err != nil {
			fmt.Println("mkdir error:", err)
		}

	case "rm":
		if len(args) < 2 {
			fmt.Println("rm: missing file/directory")
			return
		}
		path := filepath.Join(t.currentDir, args[1])
		err := os.Remove(path)
		if err != nil {
			fmt.Println("rm error:", err)
		}

	case "create":
		if len(args) < 2 {
			fmt.Println("create: missing filename")
			return
		}
		path := filepath.Join(t.currentDir, args[1])
		file, err := os.Create(path)
		if err != nil {
			fmt.Println("create error:", err)
			return
		}
		file.Close()

	case "cat":
		if len(args) < 2 {
			fmt.Println("cat: missing filename")
			return
		}
		path := filepath.Join(t.currentDir, args[1])
		content, err := os.ReadFile(path)
		if err != nil {
			fmt.Println("cat error:", err)
			return
		}
		fmt.Println(string(content))

	case "help":
		fmt.Println("Available commands:")
		fmt.Println("  exit              - exit the terminal")
		fmt.Println("  cd [path]         - change directory")
		fmt.Println("  ls                - list directory contents")
		fmt.Println("  mkdir [dir]       - create a directory")
		fmt.Println("  rm [file/dir]     - remove a file or empty directory")
		fmt.Println("  create [file]     - create an empty file")
		fmt.Println("  cat [file]        - display file contents")
		fmt.Println("  help              - show this help menu")

	default:
		fmt.Println("Unknown command:", command)
	}
}

func main() {
	// Get user’s home directory as starting point
	startDir, err := os.Getwd()
	if err != nil {
		fmt.Println("Error getting current directory:", err)
		return
	}

	terminal := Terminal{currentDir: startDir}
	reader := bufio.NewScanner(os.Stdin)

	fmt.Println("Welcome to the terminal!")
	for {
		// Print prompt showing current directory
		fmt.Printf("%s> ", terminal.currentDir)

		// Read user input
		reader.Scan()
		input := reader.Text()
		input = strings.TrimSpace(input)

		// Execute command
		terminal.Execute(input)
	}
}
