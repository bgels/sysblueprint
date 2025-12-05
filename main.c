#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>

#include <dirent.h>
#include <fcntl.h>
#include <math.h>
#include <unistd.h>
#include <time.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/sem.h>


int err(){
    printf("errno %d\n",errno);
    printf("%s\n",strerror(errno));
    exit(1);
}


int main(int argc, char* argv[]){}
