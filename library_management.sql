create table librarians(
librarian_id  number primary key,
first_name varchar(50) not null,
last_name varchar(50)  not null,
email   varchar(100)   unique not null
)
create table Members (
member_id  number primary key,
first_name varchar(50) not null,
last_name varchar(50)  not null,
email   varchar(100)   unique not null,
join_date date   default sysdate
)
create table books(
book_id number primary key,
title varchar2(100) not null,
author varchar2(100) not null,
publication_year number(4) check(publication_year >1900),
is_available char(1) check(is_available in ('Y','N'))
)

create table borrowing(
 borrowing_id number primary key,
 book_id number references books(book_id),
 member_id number references members(member_id),
 librarian_id number references librarians(librarian_id),
 borrow_date date default sysdate,
 return_date date default null
)


create sequence book_id_seq
start with 1
increment by 1;

create sequence member_id_seq
start with 100
increment by 1; 

create sequence book_id_seq
start with 1
increment by 1;

create sequence librarian_id_seq
start with 1000
increment by 100; 

create sequence borrowing_id_seq
start with 5
increment by 5; 


create or replace package library_control as
     -- Procedure to store new books's data
     procedure add_new_book(p_title books.title%type, p_author books.author%type,
     p_pub_year books.publication_year%type, p_is_valid books.is_available%type);
     
     
     --Procedure to store member's data
     procedure add_new_member(p_fname members.first_name%type, p_lname members.last_name%type,
     p_email members.email%type, p_join_date members.join_date%type);
     
     
     --Procedure to store librarian's data
     procedure add_new_librarian(p_fname librarians.first_name%type, p_lname librarians.last_name%type,
     p_email librarians.email%type);
     
     
     --Procedure to store borrowing data
     procedure add_new_borrowing(p_book_id books.book_id%type, p_mem_id members.member_id%type,p_lib_id librarians.librarian_id%type,borrow_date date);
     
     
     --Procedure to update the returned book's status
     Procedure return_book (p_borrowing_id borrowing.borrowing_id%type);
     
     
     
     --Function to get all available books that have values 'Y' and return total counts of these books .
     function get_available_books return number ;     
     
     
     
     --Display borrwings recordes for a specific members
     procedure view_member_borrowing(p_mem_id members.member_id%type);
     
     
     
     --Display the delayed books which be borrowed from more than 14 days
     Procedure show_late_books(p_result out sys_REFCURSOR);
end library_control;
/

create or replace package body library_control as


     procedure add_new_book(p_title books.title%type, p_author books.author%type,
             p_pub_year books.publication_year%type, p_is_valid books.is_available%type) as 
         begin 
             insert into books
             values (book_id_seq.nextval,p_title,p_author, p_pub_year,'Y');
             
         exception 
            when others then 
               dbms_output.put_line('UNEXPECTED ERROR from procedure add_new_book' ||sqlerrm);
         
         end add_new_book;
     
     
     
     
     procedure add_new_member(p_fname members.first_name%type, p_lname members.last_name%type,
            p_email members.email%type, p_join_date members.join_date%type) as
         begin 
             insert into members
             values (member_id_seq.nextval,p_fname ,p_lname, p_email,p_join_date);
             
         exception 
            when others then 
               dbms_output.put_line('UNEXPECTED ERROR from procedure add_new_member' ||sqlerrm);
         
         end add_new_member;
         
     
     
     
     procedure add_new_librarian(p_fname librarians.first_name%type, p_lname librarians.last_name%type,
             p_email librarians.email%type)as
         begin 
             insert into librarians
             values (librarian_id_seq.nextval,p_fname ,p_lname, p_email);
             
         exception 
            when others then 
               dbms_output.put_line('UNEXPECTED ERROR from procedure add_new_librarian' ||sqlerrm);
         
         end add_new_librarian;
         
     
     
     
     procedure add_new_borrowing(p_book_id books.book_id%type, p_mem_id members.member_id%type,p_lib_id librarians.librarian_id%type,borrow_date date)as
            v_is_available char;
         begin 
             select is_Available into v_is_available
             from books
             where book_id=p_book_id;
             
             if v_is_available = 'Y' then
                 insert into borrowing
                 values (borrowing_id_seq.nextval,p_book_id ,p_mem_id,p_lib_id,borrow_date,null);
                 
                 update books
                 set is_available='N';
             else 
                dbms_output.put_line('Sorry, this book is currently unavailable.');
             end if;
         
         exception 
            when no_data_found then 
                dbms_output.put_line('Procedure add_new_borrowing error: enter a valid value' ||sqlerrm);
            when others then 
               dbms_output.put_line('UNEXPECTED ERROR from procedure add_new_borrowing' ||sqlerrm);
         
              
         end add_new_borrowing;
         
     
     
     
     Procedure return_book (p_borrowing_id borrowing.borrowing_id%type) as
             v_return_date date ;
             v_is_available char;
             v_book_id number;
         begin 
         
             select return_date into v_return_date
             from borrowing
             where borrowing_id=p_borrowing_id;
         
             select b.is_Available, b.book_id into v_is_available,v_book_id
             from books b inner join borrowing  o
             on o.book_id=b.book_id 
             where borrowing_id=p_borrowing_id;
         
             if v_return_date IS NULL and v_is_available='N' then 
                update borrowing
                set return_date= sysdate
                where borrowing_id=p_borrowing_id;
                
                update books 
                set is_available='Y'
                where book_id=v_book_id;
                 dbms_output.put_line('Book does reterned successflly !');
             else
                 dbms_output.put_line('You already returned this book !');
             end if;
         
         
         exception 
            when no_data_found then 
                dbms_output.put_line('Procedure return_book error: enter a valid borrowing_id value' ||sqlerrm);
            when others then 
               dbms_output.put_line('UNEXPECTED ERROR from procedure return_book' ||sqlerrm);
         
         end return_book;
         
     
     
     function get_available_books return number as
             type ref_cur_type is ref cursor;
             avail_books ref_cur_type;
             v_count number:=0;
             v_book books%rowtype;
         
         begin 
             open avail_books for 
                  select * 
                  from books
                  where is_available ='Y';
             loop
                 fetch  avail_books into v_book;
                 exit when avail_books%notfound ;  
                 v_count:=v_count+1;
                 
                 dbms_output.put_line('The book number '||to_char(v_count) ||' data is :'
                                      ||chr(10) ||'Book id : '||to_char(v_book.book_id)
                                      ||chr(10) ||'Title : '|| v_book.title 
                                      ||chr(10) ||'Author : '||v_book.author
                                      ||chr(10) ||'Publication year : '||v_book.publication_year
                                      ||chr(10) ||LPAD('-', 25, '-')||chr(10));                                        
             end loop;
             
             if v_count=0 then
                dbms_output.put_line('There is no available books');
             end if;
             return v_count;
         end get_available_books;
         
     
      procedure view_member_borrowing(p_mem_id members.member_id%type) as
              cursor member_borrowing IS 
                  select m.first_name||' '||m.last_name as member_name,m.email,b.book_id,b.borrowing_id,b.borrow_date,b.return_date
                  from members m, borrowing b
                  where m.member_id=b.member_id AND b.member_id=p_mem_id;
              v_count number := 0; 
          begin
             for i in member_borrowing loop
                 v_count:=v_count+1;
                 dbms_output.put_line('Borrowing activity number '||to_char(v_count)||' :'
                                  ||chr(10) ||'Book id : '||to_char(i.book_id)
                                  ||chr(10) ||'Member name : '|| i.member_name 
                                  ||chr(10) ||'Email : '||i.email
                                  ||chr(10) ||'Borrowing id : '||i.borrowing_id
                                  ||chr(10) ||'Borrow date : '||i.borrow_date
                                  ||chr(10) ||'Return date : '||i.return_date
                                  ||chr(10) ||LPAD('-', 25, '-')||chr(10));  
             end loop;
             
             if v_count=0 then
               dbms_output.put_line('The member hasn''t any borrowing activity');
             end if;
          exception 
            when no_data_found then 
                dbms_output.put_line('Procedure view_member_borrowing error: enter a valid member_id value' ||sqlerrm);
            when others then 
               dbms_output.put_line('UNEXPECTED ERROR from procedure view_member_borrowing' ||sqlerrm);
            
          end view_member_borrowing;
          
      
      
      
      Procedure show_late_books(p_result out sys_REFCURSOR)as 
          begin 
             open p_result for 
                  select b.book_id,b.title, m.member_id,m.first_name ||' '||m.last_name as full_name,m.email
                  ,r.borrowing_id,r.borrow_date,round((sysdate-r.borrow_date),0) as days_delayed
                  from borrowing r 
                  inner join books b on b.book_id=r.book_id
                  inner join members m on m.member_id=r.member_id
                  where r.return_date IS NULL and (sysdate-r.borrow_date)>14;
          exception 
               when others then 
                    dbms_output.put_line('UNEXPECTED ERROR from procedure show_late_books' ||sqlerrm);
                
          end show_late_books;
          
end library_control;
/



BEGIN
    -- Insert books using add_new_book procedure
    library_control.add_new_book('The Great Gatsby', 'F. Scott Fitzgerald', 1925, 'Y');
    library_control.add_new_book('1984', 'George Orwell', 1949, 'Y');
    library_control.add_new_book('To Kill a Mockingbird', 'Harper Lee', 1960, 'Y');
    
    -- Insert members using add_new_member procedure
    library_control.add_new_member('Ahmed', 'Mohammed', 'ahmed.mohammed@example.com', SYSDATE);
    library_control.add_new_member('Fatima', 'Ali', 'fatima.ali@example.com', SYSDATE);
    
    -- Insert librarians using add_new_librarian procedure
    library_control.add_new_librarian('Sara', 'Khaled', 'sara.khaled@example.com');
    
    -- Insert borrowing records using add_new_borrowing procedure
    -- Assumes book_id=1, member_id=100, librarian_id=1000 for completed borrowing
    library_control.add_new_borrowing(1, 100, 1000,sysdate);
    -- Assumes book_id=2, member_id=101, librarian_id=1000 for overdue borrowing
    library_control.add_new_borrowing(2, 101, 1000,sysdate);
    -- Assumes book_id=3, member_id=101, librarian_id=1000 for active borrowing
    library_control.add_new_borrowing(3, 101, 1000,sysdate);
    

    -- Return the first borrowing using return_book procedure
    library_control.return_book(5);
    
   
end;  

select * from books;
select * from borrowing; 
select * from librarians;
select * from members;


begin 
dbms_output.put_line('Number of available books is :'||to_char(library_control.get_available_books));
end ;

exec library_control.view_member_borrowing(101);


--test
exec library_control.add_new_borrowing(3, 101, 1000,'09-JUN-25');

var c_result refcursor;
exec LIBRARY_CONTROL.show_late_books(:c_result);
print c_result;
