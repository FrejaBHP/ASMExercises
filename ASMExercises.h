#pragma once

#include <iostream>
#include <string>
#include <random>

/* Kilder:
* https://www.felixcloutier.com/x86/
* https://www.cs.virginia.edu/%7Eevans/cs216/guides/x86.html
* https://www.cs.umd.edu/class/fall2024/cmsc430/a86.html#%28part._stacks%29
* https://www.cs.uaf.edu/2008/fall/cs441/lecture/10_07_float.html
* http://www.infophysics.net/x87.pdf
* https://docs.oracle.com/cd/E19120-01/open.solaris/817-5477/eoizy/index.html
*
* https://learn.microsoft.com/en-us/cpp/assembler/inline/writing-functions-with-inline-assembly?view=msvc-160
*/

int PromptOption();

void AdditionOperations();
int addNumbersInlineOffset(int num1, int num2);
int addNumbersInlineNamed(int num1, int num2);
extern "C" int addNumbers(int num1, int num2);

void Comparison();
extern "C" int numbers(int num1, int num2, int operation, int* remainder);

void CharCount();
extern "C" void getCharsInString(char* stringPtr, int* letterArrayPtr);

void BubbleSort();
extern "C" void bubbleSort(int* numbersArrayPtr, int length);

void FPArithmetic();
extern "C" float fpA(float num1, float num2);
