1)Trigger for Handling all the Tables to which Employee is a foreign key

create or replace trigger del_rec before delete on employee
for each row
begin
	
      delete from doctor where doctor.emp_id=:old.emp_id;
      delete from other_staff where other_staff.emp_id=:old.emp_id;
      update doctor_assigned set dr_id=null where dr_id=:old.emp_id;
      update diagnosis_cost set dr_id=null where dr_id=:old.emp_id;
      
      
end;
/

2) Trigger for Handling all child Tables where Patient is a Reference
create or replace trigger del_admitted_pat before delete on patient
for each row
begin
      delete from admit where admit.patient_id=:old.pat_id;
      update doctor_assigned set pat_id=null where pat_id=:old.pat_id;
      update diagnosis_cost set pat_id=null where pat_id=:old.pat_id;

end;
/


3) Trigger to Insert values into Medical List after Inserting in Medical Charges

create or replace trigger test1 after insert on medical_charge
for each row 
declare
	cursor count is select count(serial_no) from medicallist;
	sid int;
begin
	open count;
	fetch count into sid;
	close count;
	sid:=sid+1;
	insert into medicallist values(sid,:new.medicine_id1,:new.pat_id,:new.quantity);
end;
/




4)Trigger for Intimation on Low Stock Prices


create or replace trigger stockalert after update or insert on inventory
for each row
begin 
	if (inserting) then
		if (:new.stock <3) then 
			raise_application_error(-20199,'Stocks Less Than 3');
	end if;
	elsif (updating) then 
		if (:old.stock<3) then
			raise_application_error(-20012,'Stocks Less Than 3');
	else
		dbms_output.put_line('Stocks are fine');
		end if;
	end if;
end;
/

5)Trigger for keeping a Log of the Audit and Before After Stocks on Inventory
create table redolog_values(equip_id varchar(10) , equip_name varchar(30), before_stock int,after_stock int);

create or replace trigger chk_redolog after update on inventory
for each row
begin 
    if(:new.stock<>:old.stock) then
       insert into redolog_values values(:old.equip_id,:old.equip_name,:old.stock,:new.stock);
    end if;
end;       
/








6)Trigger for Security Breach and Data Entry in Doctor Table
create table securtiy(user_name varchar2(20),current_date varchar(20), time varchar2(20));

create or replace trigger chk_trap after insert or update or delete on doctor
for each row
begin
	if(to_char(sysdate,'dy')='sat' or to_char(sysdate,'dy')='sun' or to_number(to_char(sysdate,'HH24'))<6  or to_number(to_char(sysdate,'HH24'))>22) then
		insert into security values(user,to_char(sysdate),SYSTIMESTAMP);
	end if;	
end;
/
7)Checking Valid Medicine Names 
create or replace trigger chk_cost before insert or update on pharmacy
for each row
begin
      if (:new.medicine_name is null) then
              raise_application_error(-200016,'Enter a Proper Medicine Name ');  
      end if;  
end;
/







9) Trigger for Changing Occupancy Status of a Room when allocated to a Particular Patient

create or replace trigger changestatus after insert or update on admit
for each row 
declare 
	cursor c_status is select * from room_details;
	r_status  c_status%rowtype;
begin
	open c_status ;
	loop
	fetch c_status into r_status;
		if c_status%NOTFOUND then
		exit;
		end if;
	if (r_status.room_no=:new.room_no) then
		update room_details set occupancy='Y' where room_no=:new.room_no;
	end if;
	end loop;
	close c_status;	
end;
/



:



10) To Set Salary minimum cap of 10000
create or replace trigger check_employee_salary
  before insert or update on employee
  for each row
   begin
      if (:NEW.salary < 10000 ) then
           raise_application_error(-20005,'The entered value in salary is less than 10000!!');
    end if;
    end;
    /



