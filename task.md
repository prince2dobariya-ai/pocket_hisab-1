# Khissu Database Diagram + GetX Controller Architecture

# Application Flow

```text
Salary
   ↓
Wallet
   ↓
Expenses / EMI / Hisab
   ↓
Savings
```

---

# Database Structure

## 1. salaries

```sql
CREATE TABLE salaries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  month TEXT,
  salary_amount REAL,
  wallet_added REAL,
  emi_paid REAL,
  salary_left REAL,
  created_at TEXT
);
```

---

## 2. wallets

```sql
CREATE TABLE wallets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  wallet_name TEXT,
  balance REAL,
  created_at TEXT
);
```

---

## 3. wallet_transactions

```sql
CREATE TABLE wallet_transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  wallet_id INTEGER,
  type TEXT,
  category TEXT,
  title TEXT,
  amount REAL,
  note TEXT,
  transaction_date TEXT,
  created_at TEXT
);
```

---

# Transaction Types

```text
expense
wallet_add
given
borrowed
receive_back
borrow_repayment
```

---

## 4. emis

```sql
CREATE TABLE emis (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT,
  amount REAL,
  due_date TEXT,
  is_paid INTEGER,
  created_at TEXT
);
```

---

## 5. emi_payments

```sql
CREATE TABLE emi_payments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  emi_id INTEGER,
  amount_paid REAL,
  paid_on TEXT
);
```

---

## 6. hisab_transactions

```sql
CREATE TABLE hisab_transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  person_name TEXT,
  type TEXT,
  amount REAL,
  amount_paid REAL,
  remaining_amount REAL,
  status TEXT,
  note TEXT,
  created_at TEXT
);
```

---

# Hisab Types

```text
given
borrowed
```

---

# Hisab Status

```text
pending
partial
completed
```

---

# Database Diagram

```text
┌──────────────────┐
│    SALARIES      │
├──────────────────┤
│ id               │
│ month            │
│ salary_amount    │
│ wallet_added     │
│ emi_paid         │
│ salary_left      │
└──────────────────┘


┌──────────────────┐
│     WALLETS      │
├──────────────────┤
│ id               │
│ wallet_name      │
│ balance          │
└────────┬─────────┘
         │
         │ 1:N
         │
┌────────▼─────────────────┐
│  WALLET_TRANSACTIONS     │
├──────────────────────────┤
│ id                       │
│ wallet_id                │
│ type                     │
│ category                 │
│ title                    │
│ amount                   │
│ note                     │
│ transaction_date         │
└──────────────────────────┘


┌──────────────────┐
│       EMIS       │
├──────────────────┤
│ id               │
│ title            │
│ amount           │
│ due_date         │
│ is_paid          │
└────────┬─────────┘
         │
         │ 1:N
         │
┌────────▼─────────┐
│   EMI_PAYMENTS   │
├──────────────────┤
│ id               │
│ emi_id           │
│ amount_paid      │
│ paid_on          │
└──────────────────┘


┌──────────────────────────┐
│   HISAB_TRANSACTIONS     │
├──────────────────────────┤
│ id                       │
│ person_name              │
│ type                     │
│ amount                   │
│ amount_paid              │
│ remaining_amount         │
│ status                   │
│ note                     │
└──────────────────────────┘
```

---

# Main Application Logic

## Add Money To Wallet

```text
salary_left -= amount
wallet_balance += amount
```

---

## Add Expense

```text
wallet_balance -= expense_amount
```

---

## Borrow Money

```text
wallet_balance += borrowed_amount
```

---

## Give Money

```text
wallet_balance -= given_amount
```

---

# Savings Formula

```text
Savings = Salary Left + Wallet Balance
```

---

# GetX Controller Architecture

# Folder Structure

```text
lib/
 ├── controllers/
 ├── database/
 ├── models/
 ├── screens/
 ├── widgets/
 ├── services/
 └── main.dart
```

---

# Controllers

## 1. SalaryController

Handles:

* add salary
* update salary
* calculate salary left
* salary analytics

### Responsibilities

```text
Add Salary
Update Salary
Get Current Month Salary
Calculate Salary Left
```

---

## 2. WalletController

Handles:

* wallet balance
* add money to wallet
* deduct expenses
* wallet analytics

### Responsibilities

```text
Create Wallet
Add Wallet Money
Get Wallet Balance
Update Wallet Balance
```

---

## 3. TransactionController

MOST IMPORTANT CONTROLLER

Handles:

* expenses
* wallet transactions
* category tracking
* recent activity

### Responsibilities

```text
Add Expense
Delete Expense
Get Transactions
Category Filtering
Monthly Reports
```

---

## 4. EMIController

Handles:

* EMI list
* EMI payments
* due reminders

### Responsibilities

```text
Add EMI
Pay EMI
Get Upcoming EMI
Get EMI History
```

---

## 5. HisabController

Handles:

* money given
* money borrowed
* repayments
* pending balance

### Responsibilities

```text
Add Given Money
Add Borrowed Money
Receive Payment
Repay Money
Get Pending Amount
```

---

## 6. DashboardController

Handles:

* home screen summary
* savings calculation
* analytics
* graphs

### Responsibilities

```text
Get Salary Summary
Get Wallet Summary
Get Expense Summary
Get Savings Summary
```

---

# Suggested GetX Flow

```text
UI
 ↓
Controller
 ↓
Database Service
 ↓
SQFlite
```

---

# Example Expense Flow

```text
Add Expense
   ↓
TransactionController
   ↓
Insert Into wallet_transactions
   ↓
WalletController updates balance
   ↓
Dashboard refreshes automatically
```

---

# Recommended Services

## DatabaseService

Handles:

* open database
* create tables
* migrations
* raw queries

---

## AnalyticsService

Handles:

* monthly reports
* charts
* spending insights

---

# Recommended Models

```text
SalaryModel
WalletModel
TransactionModel
EmiModel
HisabModel
```

---

# Recommended Bottom Navigation

```text
Home
Wallet
Hisab
Reports
Profile
```

---

# MVP Development Order

## Phase 1

* Salary
* Wallet
* Expenses

---

## Phase 2

* EMI
* Hisab

---

## Phase 3

* Reports
* Analytics
* Charts

---

# Final Recommended Stack

```text
Flutter
GetX
SQFlite
```

Perfect stack for Khissu MVP.
