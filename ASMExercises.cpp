#include "ASMExercises.h"

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

int main() {
    bool repeat = true;

    while (repeat) {
        int option = PromptOption();

        switch (option) {
            case 1:
                AdditionOperations();
                break;

            case 2:
                Comparison();
                break;

            case 3:
                CharCount();
                break;

            case 4:
                BubbleSort();
                break;

            case 5:
                FPArithmetic();
                break;

            case 0:
                repeat = false;

            default:
                break;
        }

        if (option != 0) {
            std::cout << "\n\n";
        }
    }
}

int PromptOption() {
    using namespace std;

    bool repeat = true;
    int option;

    cout << "Which exercise would you like to access?\n";
    cout << "1 = Addition\n2 = General integer arithmetic\n3 = Character counting\n4 = Bubblesort\n5 = Floating point multiplication\n0 = Exit\n";

    while (repeat) {
        cin >> option;

        if (cin.fail()) {
            cout << "Please enter a number\n";
            cin.clear();
            cin.ignore();
        }
        else if (option > 5 || option < 0) {
            cout << "Please enter a valid number from 0 to 5\n";
        }
        else {
            repeat = false;
        }
    }

    cout << "\n";

    return option;
}

void AdditionOperations() {
    using namespace std;
    int num1 = 1;
    int num2 = 2;
    string preString = to_string(num1) + " + " + to_string(num2) + " = ";

    int totalInline = addNumbersInlineOffset(num1, num2);
    preString = to_string(num1) + " + " + to_string(num2) + " = ";
    cout << "Inline Offset: " + preString + to_string(totalInline) + "\n";

    num1 = 3;
    num2 = 4;
    int totalInlineNamed = addNumbersInlineNamed(num1, num2);
    preString = to_string(num1) + " + " + to_string(num2) + " = ";
    cout << "Inline Named: " + preString + to_string(totalInlineNamed) + "\n";

    num1 = 5;
    num2 = 6;
    int totalExtern = addNumbers(num1, num2);
    preString = to_string(num1) + " + " + to_string(num2) + " = ";
    cout << "Extern Offset: " + preString + to_string(totalExtern) + "\n";
}

int addNumbersInlineOffset(int num1, int num2) {
    // Note to self: Inline ASM sets up and cleans up on its own, and does not need pushing, moving and popping the Base and Stack pointers
    __asm {
        ;push   ebp
        ;mov    ebp, esp

        mov     eax, [ebp + 8]
        mov     ecx, [ebp + 12]
        add     eax, ecx

        ;pop    ebp
        ;ret
    }
}

int addNumbersInlineNamed(int num1, int num2) {
    // Note to self: Inline ASM can use parameter names instead of offsets
    __asm {
        mov     eax, num1
        mov     ecx, num2
        add     eax, ecx
    }
}

// Performs arithmetic on two integers, depending on the value of the 'operation' variable, which is compared in ASM
void Comparison() {
    using namespace std;

    int num1;
    int num2;
    int operation;
    int divRemainder = 0;

    cout << "Enter first integer: ";
    cin >> num1;

    cout << "Enter second integer: ";
    cin >> num2;

    cout << "Enter integer for operation (0 is +, 1 is -, 2 is *, 3 is /): ";
    cin >> operation;

    int result = numbers(num1, num2, operation, &divRemainder);

    if (operation == 3) {
        cout << "Result is " + to_string(result) + " with remainder " + to_string(divRemainder);
    }
    else {
        cout << "Result is " + to_string(result);
    }

    /* Called ASM is equivalent to:
    int result;
    switch (operation) {
        case 0:
            result = num1 + num2;
            break;

        case 1:
            result = num1 - num2;
            break;

        case 2:
            result = num1 * num2;
            break;

        case 3:
            result = num1 / num2;
            divRemainder = num1 % num2;
            break;

        default:
            break;
    }
    */
}

void CharCount() {
    // Char is 1 byte
    using namespace std;

    int letterArray[26]{ 0 };

    cout << "Enter string you want analysed: ";

    cin.ignore();

    string newstring;
    getline(cin, newstring);

    char* cStrPtr = new char[newstring.length() + 1];
    strcpy_s(cStrPtr, newstring.length() + 1, newstring.c_str());

    getCharsInString(cStrPtr, letterArray);

    cout << "Letters used:\n";
    for (size_t i = 0; i < size(letterArray); i++) {
        if (letterArray[i] != 0) {
            char letter{ char(65 + i) };
            printf("%c: %d\n", letter, letterArray[i]);
        }
    }
}

void BubbleSort() {
    using namespace std;

    random_device rnd;
    mt19937 gen(rnd());
    uniform_int_distribution<mt19937::result_type> amountOfNumbersRange(15, 30);
    uniform_int_distribution<mt19937::result_type> numbersValueRange(0, 100);

    vector<int> numbersList(amountOfNumbersRange(gen));

    cout << "Original array:\n";
    for (size_t i = 0; i < numbersList.capacity(); i++) {
        numbersList[i] = numbersValueRange(gen);
        cout << to_string(numbersList[i]) + " ";
    }

    bubbleSort(numbersList.data(), numbersList.capacity() - 1);

    cout << "\n\nSorted array:\n";
    for (size_t i = 0; i < numbersList.capacity(); i++) {
        cout << to_string(numbersList[i]) + " ";
    }
    cout << "\n";
}

void FPArithmetic() {
    using namespace std;

    float num1;
    float num2;

    cout << "Enter first number: ";
    cin >> num1;

    cout << "Enter second number: ";
    cin >> num2;

    float result = fpA(num1, num2);
    printf("%.3f * %.3f = %.3f", num1, num2, result);
    cout << "\n";
}
