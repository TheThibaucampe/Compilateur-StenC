#include "binaryconvert.h"

int convertBinaryToDecimal(long long n)
{
    int decimalNumber = 0, i = 0, remainder;
    while (n!=0)
    {
        remainder = n%10;
        n /= 10;
        decimalNumber += remainder*pow(2,i);
        ++i;
    }
    return decimalNumber;
}

int convert (char* yytext)
{
	if (strlen(yytext) >= 2)
	{
		if (yytext[0] == '0') //Conversion incoming
		{
			if (yytext[1] == 'b') //C'est un binaire
			{
				return convertBinaryToDecimal(atoll(strstr(yytext, &yytext[2])));
			} else
			if (yytext[1] == 'x') //C'est un héxa
			{
				return (int)strtol(strstr(yytext, &yytext[2]), (char **)NULL, 16);
			} else 					//C'est un octal
			{ 
				return (int)strtol(strstr(yytext, &yytext[1]), (char **)NULL, 8);
			}
		} else
		{
			return atoi(yytext);
		}
	} else
	{
		return atoi(yytext);
	}
}
