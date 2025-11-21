#include <stdio.h>

int main(int argc, char* argv[])
{
    // If no additional arguments, print default greeting
    if (argc == 1) {
        printf("Hello, world!\n");
    } else {
        // Loop through all provided arguments (skip argv[0], the program name)
        for (int i = 1; i < argc; i++) {
            printf("Hello, %s!\n", argv[i]);
        }
    }

    return 0;
}