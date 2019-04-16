//
// Created by sweetsleep on 4/8/19.
//
#include <stdio.h>

int main(int argc, char *argv[]) {
        char* str = "index.html";
        unsigned long hash = 5381;
        int c;

        while (c = *str++)
            hash = ((hash << 5) + hash) + c; /* hash * 33 + c */

        printf("%d",hash);

    return 0;
}