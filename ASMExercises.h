#pragma once

#include <iostream>
#include <string>
#include <random>

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
