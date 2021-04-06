clear screen;

drop table Customers;
drop table Deals;
drop table TCash;
drop table TRemains;

create table Customers(customer_phoneNumber VARCHAR2(11) UNIQUE, customer_name VARCHAR2(12), address VARCHAR2(30));
create table Deals(deal_id number, customer_phoneNumber VARCHAR2(11), given float, remain float, dealDate DATE, reason VARCHAR2(20));
create table TCash(dealDate DATE, totalCash float, customer_phoneNumber VARCHAR2(11) UNIQUE) ;
create table TRemains(RemainDate DATE, totalRemain float, customer_phoneNumber VARCHAR2(11) UNIQUE);

commit;
