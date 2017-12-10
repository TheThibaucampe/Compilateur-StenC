#include "binaryconvert.h"

//Convert a binary number (in base 10) into a decimal number
int convertBinaryToDecimal(long long n)
{
    int decimalNumber = 0, i = 0, reminder;
    while (n!=0)
    {
        reminder = n%10;
        n /= 10;
        decimalNumber += reminder*pow(2,i);
        ++i;
    }
    return decimalNumber;
}

//Convert a string into a decimal
int convert (char* yytext)
{
	if (strlen(yytext) >= 2)
	{
		if (yytext[0] == '0') //Conversion incoming !
		{
			if (yytext[1] == 'b') //Binary
			{
				return convertBinaryToDecimal(atoll(strstr(yytext, &yytext[2])));
			} else
			if (yytext[1] == 'x') //Hexadecimal
			{
				return (int)strtol(strstr(yytext, &yytext[2]), (char **)NULL, 16);
			} else 	//Octal
			{ 
				return (int)strtol(strstr(yytext, &yytext[1]), (char **)NULL, 8);
			}
		} else if (yytext[0] == '-') //Negative number
		{
			if (yytext[1] == '0') //Conversion incoming
      {
      	if (yytext[2] == 'b') //Binary
    		{
        	return convertBinaryToDecimal(atoll(strstr(yytext, &yytext[3])));
       	} else if (yytext[2] == 'x') //Hexadecimal
       	{
       	  return (int)strtol(strstr(yytext, &yytext[3]), (char **)NULL, 16);
       	} else	//Octal
      	{
       	  return (int)strtol(strstr(yytext, &yytext[2]), (char **)NULL, 8);
       	}
			} else
			{
				return atoi(yytext);
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