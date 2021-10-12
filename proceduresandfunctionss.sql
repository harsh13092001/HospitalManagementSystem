
1)Procedure to Input Room Type and Get List of Rooms in that Types and their Details

create or replace procedure roomdetails as
cursor c_type is select * from type;
r_type c_type%rowtype;
cursor c_room_type (typename type.room_typename%type) is select * from room_details where room_type=typename;
r_room_type c_room_type%rowtype;
begin
open c_type;
loop
fetch c_type into r_type;
if c_type%notfound then
exit;
end if;
open c_room_type(r_type.room_typename);
loop
fetch c_room_type into r_room_type;
if c_room_type%notfound then
exit;
end if;
dbms_output.put_line(r_type.room_typename||' '||r_room_type.room_no ||' '||r_room_type.occupancy||''||r_room_type.occupancy_days);
end loop;
close c_room_type;
end loop;
close c_type;
end;
/




2)For Giving List of Doctors and Patients Assigned to Them

create or replace procedure doctorassigned as 
cursor c_doctor is select * from doctor;
r_doctor c_doctor%rowtype;
cursor c_docpat (doctorid doctor.emp_id%type) is select * from doctor_assigned where dr_id=doctorid;
r_docpat c_docpat%rowtype;
begin
open c_doctor;
loop
fetch c_doctor into r_doctor;
if c_doctor%notfound then
exit;
end if;
open c_docpat (r_doctor.emp_id);
loop
fetch c_docpat into r_docpat;
if c_docpat%notfound then 
exit;
end if;
dbms_output.put_line(r_doctor.emp_id||' '||r_docpat.pat_id);
end loop;
close c_docpat;
end loop;
close c_doctor;
end;
/







3) For Calculating Final Bill
create or replace procedure finalbill(pat_id varchar, treatment_id varchar) as
cursor c_patient is select * from patient;
r_patient c_patient%rowtype;
cursor c_treatments is select * from treatments;
r_treatments c_treatments%rowtype;
cursor c_admit(patientid patient.pat_id%type) is select * from admit where pat_id=patientid;
r_admit c_admit%rowtype;
cursor c_room_details(roomno admit.room_no%type) is select * from room_details;
r_room_details c_room_details%rowtype;
patientid varchar(20);
treatmentid varchar(20);
case_number varchar(20);
billing_date date;
room_no varchar(20);
room_charges int;
treatment_charge int;
tot int;
begin
for r_patient in c_patient loop
if (r_patient.pat_id=pat_id) then
patientid:=r_patient.pat_id;
end if;
end loop;
for r_treatments in c_treatments loop
if(r_treatments.treatment_id=treatment_id) then
treatmentid:=r_treatments.treatment_id;
treatment_charge:=r_treatments.charge;
end if;
end loop;
open c_admit (patientid);
loop 
fetch c_admit into r_admit;
if c_admit%notfound then 
exit;
end if;
case_number:=r_admit.case_number;
room_no:=r_admit.room_no;
end loop;
close c_admit;
open c_room_details (room_no);
loop 
fetch c_room_details into r_room_details;
if c_room_details%notfound then
exit;
end if;
room_charges:=r_room_details.occupancy_days*r_room_details.charge_of_room;
end loop;
close c_room_details;
tot:=room_charges+treatment_charge;
dbms_output.put_line(tot);
insert into final_bill values()
end;
/





4)Procedure to Input Patient ID and retrieve data of Room in which he is admitted, Diagnosis Cost and Other Details 

create or replace procedure patdetail(pat_id varchar) as 
cursor c_patient is select * from patient;
r_patient c_patient%rowtype;
cursor c_admit (patid patient.pat_id%type) is select * from admit where pat_id=patid;
r_admit c_admit%rowtype;
cursor c_diagnosiscost (patid patient.pat_id%type) is select * from diagnosis_cost where pat_id=patid;
r_diagnosiscost c_diagnosiscost%rowtype;
begin
open c_patient;
loop
fetch c_patient into r_patient;
if c_patient%notfound then
exit;
end if;
open c_admit (r_patient.pat_id);
loop
fetch c_admit into r_admit;
if c_admit%notfound then
exit;
end if;
dbms_output.put_line(r_patient.pat_id||'    '||r_patient.fname||'   '||r_patient.lname||'   '|| r_admit.room_no||' '||r_admit.case_number);
end loop;
close c_admit;
end loop;
close c_patient;
end;
/





5) For accessing List of Employees in a department
create or replace procedure doclist (dept_id varchar) as
cursor c_dept is select * from department ;
r_dept c_dept%rowtype;
cursor c_doc (deptid department.dept_id%type) is select * from doctor where dept_id=deptid;
r_doc c_doc%rowtype;
dc int;
begin 
open c_dept;
loop
dc:=0;
fetch c_dept into r_dept;
if c_dept%notfound then
exit;
end if;
open c_doc(r_dept.dept_id);
loop
fetch c_doc into r_doc;
if c_doc%notfound then
exit;
end if;
dc:=dc+1;
dbms_output.put_line(r_dept.dept_name||' '|| r_doc.emp_id);
end loop;
dbms_output.put_line('Number of Doctors in Department'||' '||dc);
close c_doc;
end loop;
close c_dept;
end;
/







6)Input Department and get list of available Treatments

create or replace procedure availabletreatments(dept_id varchar) as
cursor c_dept is select * from department ;
r_dept c_dept%rowtype;
cursor c_treatment(deptid department.dept_id%type) is select * from treatments where dep_id=deptid;
r_treatment c_treatment%rowtype;
begin
open c_dept;
loop
fetch c_dept into r_dept;
if c_dept%notfound then
exit;
end if;
open c_treatment(r_dept.dept_id);
loop
fetch c_treatment into r_treatment;
if c_treatment%notfound then
exit;
end if;
dbms_output.put_line(r_dept.dept_id||' '||r_dept.dept_name||' '||r_treatment.treatment_name);
end loop;
close c_treatment;
end loop;
close c_dept;
end;
/




7)Input Department and Get all necessary Inventory details Department wise
create or replace procedure Department_equip(dept_name varchar) as
  cursor C_depart is select * from department;
  cursor C_equip is select * from inventory;
  r_depart c_depart%rowtype;
  r_equip c_equip%rowtype;
begin
     for r_depart in c_depart loop
         if( r_depart.dept_name = dept_name)then
              dbms_output.put_line('Department name =' || dept_name);
              dbms_output.put_line('Equipment'||'    '||'Equipment id'||'    '||'cost'||'   '||'Existing stock' );
              for r_equip in C_equip loop
                   if(r_equip.dept_id = r_depart.dept_id) then
                        dbms_output.put_line(r_equip.equip_name||'    '||r_equip.equip_id||'    '||r_equip.cost||'   '||r_equip.stock);
                   end if; 
              end loop;
         end if;
       end loop;
end;
/




8)Function to print the number of Rooms Available

create or replace function room_available return int as
       cursor c_room is select * from room_details;
       r_room c_room%rowtype;
       d int := 0;
begin
      for r_room in c_room loop
         if(r_room.occupancy = 'N') then
           d := d + 1;
         end if;
      end loop;
      return d;
end;
/





