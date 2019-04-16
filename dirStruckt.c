//
// Created by sweetsleep on 4/13/19.
//
#include <dirent.h>
#include <stdlib.h>
#include <stdio.h>
int main(int argc, char *argv[]){

    struct  dirent dir;

    printf("%d\n", sizeof(dir.d_ino));
    printf("%d\n", sizeof(dir.d_off));
    printf("%d\n", sizeof(dir.d_reclen));
    printf("%d\n", sizeof(dir.d_name));
    printf("%d\n", sizeof(dir.d_type));
    return 0;
}

284