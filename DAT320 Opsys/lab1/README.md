# Lab 1: Introduction to Unix

| Lab 1: | Introduction to Unix |
| ---------------------    | --------------------- |
| Subject:                 | DAT320 Operating Systems and Systems Programming |
| Deadline:                | **November 1, 2025 23:59** |
| Grading:                 | Pass/fail |
| Submission:              | Individually |

## Table of Contents

1. [Introduction](#introduction)
2. [Learning Objectives](#learning-objectives)
3. [Linux Lab](#linux-lab)
4. [The Missing Semester of Your CS Education by MIT](#the-missing-semester-of-your-cs-education-by-mit)
5. [Additional Resources and Tips](#additional-resources-and-tips)
6. [Task: Unix/Linux and Git Multiple-Choice Questions](#task-unixlinux-and-git-multiple-choice-questions)
7. [Submitting to QuickFeed](#submitting-to-quickfeed)

## Introduction

The overall aim of the labs in this course is to learn how to develop systems where you need to access operating system resources, and that may require some low-level tuning to obtain the desired performance.
We will do this through a series of lab assignments that will expose you to numerous developer tools, and by developing applications in the Go programming language.
We will not implement our own operating system, but in some of the assignments we try to emulate pieces of an operating system, such as memory management and scheduling.

In this first lab though, we will get started with some command-line tools, some of which are based on the Missing Semester course from MIT.

## Learning Objectives

After completing this lab, you should be able to:

- Use the Unix shell to navigate the file system, manipulate files and directories, and run programs.
- Use Git to manage your source code.
- (Optional) Use SSH to log into remote machines.

## Linux Lab

Most lab assignments can be performed on your local machine.
If you already run Linux or macOS on your laptop, you should be ready to go.
Linux and macOS are to a large extent relatively similar at the command level.
If you are running Windows, please consult the instructions [here](https://github.com/dat320-2025/info/blob/main/setup-wsl.md).

## The Missing Semester of Your CS Education by MIT

Throughout this and other courses and as a software engineer, you will often need to use command-line tools to interact with computers.
Lack of knowledge of the available tools will lead to manually performing repetitive tasks or spending lots of time searching online for solutions.
For these reasons and more, we expect you to go through [The Missing Semester of Your CS Education](https://missing.csail.mit.edu/) from MIT (hereafter referred to as the Missing Semester).
You can read more about the motivation behind that course [here](https://missing.csail.mit.edu/about/).

You should try to answer or at least understand the answers to the **Exercises** section at the end of each lecture.
Additionally we give a set of multiple choice questions below, which mostly correspond to lectures 1, 2, 4, 5, and 6.

### Additional Resources and Tips

- [UNIX Tutorial for Beginners](http://www.ee.surrey.ac.uk/Teaching/Unix/).
  Eight simple tutorials covering the basics of various Unix/Linux commands.
  You may use these as a reference if you struggle to answer some of the questions or want a more in-depth overview than that offered by the Missing Semester.

- [Unix/Linux Command Reference](https://files.fosswire.com/2007/08/fwunixref.pdf).
  A cheat sheet of several frequently used Unix/Linux commands.

- Remember that almost every Unix/Linux command has a manual page, or man page for short, which can be accessed with `man` command, e.g. `man ls` for the `ls` command.

- *Tip:* Use the `git help` command whenever in doubt about a Git command.
  It lets you read more about the functionality of each of Git's subcommands, e.g. by running `git help commit` for information about `git commit`, such as options, or `git help pull` for information about `git pull`.

- *Tip:* Navigating `man`, `less` and `git help` buffers: The buffers opened by the `man`, `less` and `git help` commands support vi(m)-like navigation.
  - You can move down by one line by pressing the `Down` arrow key or the `j` key, or up by one line by pressing the `Up` arrow key or the `k` key.
  - You can move up or down by one page by pressing the `PageUp` and `PageDown` keys.
    Alternatively you can press the `f` ("forward") or `b` ("backward") keys.
  - You can go to the start or end of the buffer by pressing the respective `Home` and `End` keys.
    Alternatively you can press the `g` or `G` keys for the same functionality.
    There are often examples at the end of man pages.
  - You can search for some text by pressing the `/` key.
    Press `n` to go to the next match, and `N` to go to the previous match.

### Task: Unix/Linux and Git Multiple-Choice Questions

Answer the questions inline in the markdown files, as explained in the heading of each file.

1. [Questions related to the Missing Semester](./missing_semester_questions.md) lectures 1, 2 and 4.
2. [Shell questions](shell_questions.md).
   Some of these commands may not be covered by the Missing Semester lectures.
   We recommend reading the relevant man pages and checking the other related resources mentioned above.
3. [Questions about Git](./git_questions.md) based on lecture 6 of the Missing Semester as well as some regularly used Git commands.
   *Hint:* Some of the questions may be heavily influenced by StackOverflow questions.

Note that, some commands behave differently on macOS and Linux, because they are based on different heritage.
Typically, macOS and Linux may sometimes use different flags for altering the behavior of a command.
We have made notes on these differences, where we are aware of them, but should you discover an incompatibility in these labs, please let us know.

Further, this lab was designed with the `bash` Unix shell, which is the default on Linux.
The default shell is `zsh` on macOS.
If you experience any issues related to running a different shell than `bash`, please try the same on Linux, and let us know.
To determine your shell, use the following command:

```console
echo $SHELL
```

#### Setting up SSH Authentication on GitHub

Setting up SSH authentication on GitHub is optional, but it is recommended. It allows you to authenticate with GitHub without entering your username and password every time you push or pull from a repository.

Follow the instructions for [Connecting to GitHub with SSH](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh) including the step [Testing your SSH connection](https://docs.github.com/en/github/authenticating-to-github/testing-your-ssh-connection).
Note that these guides provide a slight variation for Mac, Windows and Linux.
You can select your OS via a tab near the top of each article, and for operations on the Linux labs you should follow the instructions in the `Linux` tab.

## Submitting to QuickFeed

Read our [lab submission guide](https://github.com/dat320-2025/info/blob/main/lab-submission.md) for more detailed instructions on how to submit your assignments to be evaluated by QuickFeed.
