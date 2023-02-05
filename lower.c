// lower.c

#include <stdio.h>
#include <ctype.h>

// Covers string to lowercase
void Lower(char *str)
{
    for (int i = 0; str[i]; i++) {
        str[i] = tolower(str[i]);
    }
}


int main (void)
{
    char str[] = "Four SCORE AND 0 SERVEN years GO. asldkjfak 12308345 <>#@$%$#^";
    printf("%s\n", str);
    Lower(str);
    printf("%s\n", str);
    return 0;
}
