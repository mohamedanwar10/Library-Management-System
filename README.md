# Library-Management-System
This system is an advanced Oracle SQL-based library management solution, containing:

- **Tables**: 
  - `librarians` (librarian details)
  - `members` (member info with join date)
  - `books` (book details including availability)
  - `borrowing` (loan records)
- **Sequences**: Auto-generated IDs for books, members, librarians, and borrowings.
- **Package `library_control`**: Offers functionalities including:
  - Adding new books, members, and librarians.
  - Recording borrowings and updating book availability to "N".
  - Managing book returns by setting availability to "Y".
  - Retrieving the count of available books ("Y").
  - Viewing borrowing history for a specific member.
  - Identifying overdue books (over 14 days without return).

## What It Does
The system automates library operations, reduces manual effort, ensures accurate tracking of books and loans, and provides real-time reports on availability and delays.

## Benefits
- Improves efficiency.
- Minimizes errors.
- Enhances user experience for library staff and members.

## Who It’s For
Ideal for librarians, library administrators, educational institutions, and any organization needing efficient book and loan management.

## Usage
- Run the SQL script to set up tables, sequences, and the package.
- Utilize the procedures and functions to manage and report library data.
- Test with the included sample insertions.

## Requirements
- Oracle Database environment.
- Basic SQL and PL/SQL knowledge for customization.
