#include <iostream>
#include <string>
#include <vector>

using namespace std;

// Базовый класс BankAccount
class BankAccount {
protected:
    string accountNumber;
    string ownerName;
    double balance;

public:
    // Конструктор
    BankAccount(string accNum, string owner, double initialBalance = 0.0)
        : accountNumber(accNum), ownerName(owner), balance(initialBalance) {}

    // Метод для пополнения счета
    virtual void deposit(double amount) {
        if (amount > 0) {
            balance += amount;
            cout << "Пополнение счета " << accountNumber 
                 << " на " << amount << " рублей" << endl;
        } else {
            cout << "Неверная сумма для пополнения!" << endl;
        }
    }

    // Метод для снятия средств
    virtual void withdraw(double amount) {
        if (amount > 0 && amount <= balance) {
            balance -= amount;
            cout << "Снятие со счета " << accountNumber 
                 << " суммы " << amount << " рублей" << endl;
        } else {
            cout << "Недостаточно средств или неверная сумма!" << endl;
        }
    }

    // Метод для получения баланса
    double getBalance() const {
        return balance;
    }

    // Метод для вывода информации
    virtual void displayInfo() const {
        cout << "Счет: " << accountNumber << endl;
        cout << "Владелец: " << ownerName << endl;
        cout << "Баланс: " << balance << " рублей" << endl;
    }

    // Виртуальный деструктор
    virtual ~BankAccount() {}
};

// Производный класс SavingsAccount
class SavingsAccount : public BankAccount {
private:
    double interestRate; // Процентная ставка

public:
    // Конструктор
    SavingsAccount(string accNum, string owner, double initialBalance, double rate)
        : BankAccount(accNum, owner, initialBalance), interestRate(rate) {}

    // Метод для начисления процентов
    void applyInterest() {
        double interest = balance * interestRate / 100.0;
        balance += interest;
        cout << "Начислены проценты по счету " << accountNumber 
             << ": " << interest << " рублей" << endl;
    }

    // Переопределение метода вывода информации
    void displayInfo() const override {
        BankAccount::displayInfo();
        cout << "Процентная ставка: " << interestRate << "%" << endl;
    }

    // Геттер для процентной ставки
    double getInterestRate() const {
        return interestRate;
    }
};

int main() {
    cout << "=== Банковская система ===" << endl << endl;

    // Создание обычного банковского счета
    BankAccount regularAccount("1234567890", "Иванов Иван Иванович", 50000.0);
    
    cout << "Обычный банковский счет:" << endl;
    regularAccount.displayInfo();
    
    cout << "\nОперации по обычному счету:" << endl;
    regularAccount.deposit(15000.0);
    regularAccount.withdraw(20000.0);
    
    cout << "\nТекущий баланс: " << regularAccount.getBalance() << " рублей" << endl;

    cout << "\n" << string(40, '=') << "\n" << endl;

    // Создание сберегательного счета
    SavingsAccount savingsAccount("0987654321", "Петрова Мария Сергеевна", 100000.0, 5.0);
    
    cout << "Сберегательный счет:" << endl;
    savingsAccount.displayInfo();
    
    cout << "\nОперации по сберегательному счету:" << endl;
    savingsAccount.deposit(50000.0);
    savingsAccount.withdraw(30000.0);
    savingsAccount.applyInterest();
    
    cout << "\nИнформация после операций:" << endl;
    savingsAccount.displayInfo();

    cout << "\n=== Работа программы завершена ===" << endl;

    return 0;
}