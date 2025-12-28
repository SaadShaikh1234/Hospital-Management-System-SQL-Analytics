create database hospital_management_system;
use hospital_management_system;

create table doctors(doctor_id varchar(10) unique not null, first_name varchar(50) not null, last_name varchar(50) not null, specialization varchar(50) not null, phone_number varchar(20), years_experience int, hospital_branch varchar(50), email varchar(50), primary key (doctor_id));
select * from doctors;

create table patients(patient_id varchar(10) unique not null, first_name varchar(50) not null, last_name varchar(50) not null, gender varchar(2) not null, date_of_birth date, contact_number varchar(20) not null, address varchar(50) not null, registration_date date not null,insaurance_provider varchar(50) not null, insaurance_number varchar(20) not null, email varchar(50) not null, primary key (patient_id));
select * from patients;

create table appointments(appointment_id varchar(10) unique not null,patient_id varchar(10) not null, doctor_id varchar(10) not null, appointment_date date, appointment_time time not null, reason_for_visit varchar(50) not null, status varchar(50) not null, primary key (appointment_id), foreign key (patient_id) references patients(patient_id), foreign key (doctor_id) references doctors(doctor_id));
select * from appointments;

create table treatments(treatment_id varchar(10) unique not null, appointment_id varchar(10) not null, treatment_type varchar(50) not null, description varchar(100) not null, cost decimal(10, 2) not null, treatment_date date not null, primary key (treatment_id), foreign key (appointment_id) references appointments(appointment_id));
select * from treatments;

create table billing(bill_id varchar(10) unique not null, patient_id varchar(10) not null,treatment_id varchar(10) not null, bill_date date not null, amount decimal(10, 2) not null, payment_method varchar(50) not null, payment_status varchar(50) not null, primary key (bill_id), foreign key (patient_id) references patients(patient_id), foreign key (treatment_id) references treatments(treatment_id));
select * from billing;

describe appointments;
describe doctors;
describe patients;
describe treatments;
describe billing;

-- Basic SQL & Data Understanding
-- 1. List all patients with their full name, gender, and insurance provider
select concat(first_name, ' ', last_name) as full_name, gender, insaurance_provider from patients;
-- 2. Show all doctors and their specializations and hospital branches
select concat(first_name, ' ', last_name) as full_name, specialization, hospital_branch from doctors;
-- 3. Retrieve all appointments with status is 'Scheduled'.
select * from appointments where status = 'Scheduled';
-- 4. Display treatments that cost more than 1,000
select * from treatments where cost>1000;
-- 5. List all unpaid bills
select * from billing where payment_status IN ('Pending' , 'Failed');

-- Patient Analytics
-- 1. Count the total number of patients by gender
select gender,count(*) from patients group by gender;
-- 2. Identify patients who do not have insurance
select concat(p.first_name, ' ', p.last_name) as full_name, a.patient_id from appointments a left join patients p on p.patient_id= a.patient_id where p.insaurance_provider is null;
-- 3. Find the top 5 oldest patients
select * from patients order by date_of_birth asc  LIMIT 5;
-- 4. Find patients who have had more than 3 appointments
select p.patient_id, concat(p.first_name, ' ', p.last_name) as full_name, count(a.appointment_id) as count from patients p left join appointments a  on p.patient_id = a.patient_id group by patient_id, full_name having count>3;
-- 5. List patients who have never had an appointment
select p.patient_id, concat(p.first_name, ' ', p.last_name) as full_name, count(a.appointment_id) as count from patients p left join appointments a  on p.patient_id = a.patient_id group by patient_id, full_name having count=0;

-- Doctor & Staff Performance Analysis
-- 1. Count the number of doctors per specialization
select specialization, count(doctor_id) as count from doctors group by specialization;
-- 2. Find doctors with more than 10 years of experience
select doctor_id, concat(first_name, ' ', last_name) as full_name, years_experience from doctors where years_experience>=10;
-- 3. Identify doctors who have handled the highest number of appointments
select d.doctor_id, concat(d.first_name, ' ', d.last_name) as full_name, count(a.appointment_id) as total_appointment from doctors d left join appointments a on d.doctor_id = a.doctor_id group by doctor_id, full_name order by total_appointment Desc Limit 3;
-- 4. Calculate the average years of experience per hospital branch
select hospital_branch, avg(years_experience) as avg_experience from doctors group by hospital_branch;
-- 5. Find doctors who have no appointments scheduled
select d.doctor_id, concat(d.first_name, ' ', d.last_name) as full_name, count(a.appointment_id) as total_appointment from doctors d left join appointments a on d.doctor_id = a.doctor_id group by doctor_id, full_name having total_appointment = 0;

-- Appointment Analysis
-- 1. Count total appointments per month
select month(appointment_date) as sr_number, monthname(appointment_date) as appointment_month, count(appointment_id) as count from appointments group by appointment_month, sr_number order by sr_number;
-- 2. Find the most common reason for visit
select reason_for_visit, count(appointment_id) as count from appointments group by reason_for_visit order by count desc limit 1;
-- 3. Identify the appointment cancellation rate
select status, count(appointment_id) as cancellation_rate from appointments group by status having status = 'Cancelled';
-- 4. Find patients who missed appointments (status = Cancelled or No-Show)
select concat(p.first_name, ' ', p.last_name) as full_name, a.status from appointments a left join  patients p on a.patient_id=p.patient_id where status in ('Cancelled', 'No-show');
-- 5. Determine the busiest doctor based on number of appointments
select d.doctor_id, concat(d.first_name, ' ', d.last_name) as full_name, count(a.appointment_id) as count from appointments a left join doctors d on a.doctor_id = d.doctor_id group by full_name, doctor_id order by count desc limit 1;

-- Treatment & Medical Insights
-- 1. Count the number of treatments per treatment type
select treatment_type, count(treatment_id) as count from treatments group by treatment_type;
-- 2. Find the most expensive treatment
select treatment_type, cost from treatments order by cost desc limit 1;
-- 3. Calculate the average treatment cost
select treatment_type, avg(cost) as average_cost from treatments group by treatment_type;
-- 4. List appointments that resulted in multiple treatments
select t.appointment_id, count(t.treatment_id) AS treatment_count from treatments t group by t.appointment_id having count(t.treatment_id) > 1;
-- 5.  Identify treatments that were never billed
select t.treatment_id, b.bill_id from treatments t left join billing b on t.treatment_id = b.treatment_id where b.bill_id is null;

-- Billing & Revenue Analysis
-- 1. Calculate total revenue generated by the hospital
select sum(amount) as total_revenue from billing;
-- 2. Find total revenue per month
select month(bill_date) as sr_no, monthname(bill_date) as month, sum(amount) as revenue from billing group by month,sr_no order by sr_no asc;
-- 3. Identify the top 5 patients by total billing amount
select p.patient_id, concat(p.first_name, ' ', p.last_name) as full_name, sum(b.amount) as amount from billing b left join patients p on b.patient_id = p.patient_id group by full_name, patient_id order by amount desc limit 5;
-- 4. Calculate pending (unpaid) amount
select sum(amount) as unpaid_amount from billing where payment_status in ('Pending', 'Failed');
-- 5. Find the most common payment method
select payment_method, count(bill_id) as count from billing group by payment_method order by count desc limit 1;

-- Advanced JOIN
-- 1. Display patient name, doctor name, appointment date, and treatment cost
select concat(p.first_name, ' ', p.last_name) as patient_name, concat(d.first_name, ' ', d.last_name) as doctor_name, a.appointment_date, t.cost as treatment_cost from appointments a left join patients p on p.patient_id = a.patient_id left join doctors d on a.doctor_id = d.doctor_id left join treatments t on a.appointment_id = t.appointment_id;
-- 2. Find doctors whose patients generated the highest total revenue
select concat(d.first_name, ' ', d.last_name) as doctor_name, sum(b.amount) as revenue from appointments a left join doctors d on d.doctor_id = a.doctor_id left join billing b on a.patient_id = b.patient_id group by doctor_name order by revenue desc limit 1;
-- 3. Identify patients who had appointments but no treatments
select p.patient_id, concat(p.first_name, ' ', p.last_name) as patient_name, a.appointment_id, sum(t.treatment_id) as treatments from appointments a left join patients p on a.patient_id = p.patient_id left join treatments t on a.appointment_id = t.appointment_id group by p.patient_id, patient_name, a.appointment_id  having count(t.treatment_id)=0;
-- 4. Find treatments along with billing payment status
select t.treatment_id, b.bill_id, b.payment_status from treatments t left join billing b on t.treatment_id = b.treatment_id;
-- 5. Show hospital branch-wise total revenue generated
select d.hospital_branch, sum(t.cost) as revenue from appointments a left join doctors d on a.doctor_id = d.doctor_id left join treatments t on a.appointment_id = t.appointment_id group by hospital_branch;

-- Subqueries & CTEs (Advanced Analytics)
-- 1. Find patients whose total billing is above average
select concat(p.first_name, ' ', p.last_name) as patient_name, sum(b.amount) as total_billing from patients p left join billing b on p.patient_id = b.patient_id where amount > (select avg(amount) as amount from billing) group by patient_name order by total_billing DESC;
-- 2. Identify doctors who treat patients with high-cost treatments (> avg)
select d.doctor_id, concat(d.first_name, ' ', d.last_name) as doctor_name, sum(t.cost) as cost from appointments a left join doctors d on d.doctor_id = a.doctor_id left join treatments t on a.appointment_id = t.appointment_id where cost > (select avg(cost) as cost from treatments) group by doctor_id, doctor_name order by cost DESC;
-- 3. Rank doctors based on total revenue generated
select doctor_id, doctor_name, cost, row_number() over (order by cost desc) as Ranks  from (select d.doctor_id, concat(d.first_name, ' ', d.last_name) as doctor_name, sum(t.cost) as cost from appointments a left join doctors d on d.doctor_id = a.doctor_id left join treatments t on a.appointment_id = t.appointment_id group by doctor_name, doctor_id) sub;
-- 4. Find the second highest billed patient
with PatientBilling as (select p.patient_id, concat(p.first_name, ' ', p.last_name) as patient_name, sum(b.amount) as total_billed, dense_rank() over (order by SUM(b.amount) desc) as RankNum from billing b left join treatments t on b.treatment_id = t.treatment_id left join appointments a on t.appointment_id = a.appointment_id join patients p on a.patient_id = p.patient_id group by p.patient_id, patient_name) select patient_id, patient_name, total_billed from PatientBilling where RankNum = 2;
-- 5. Calculate running total of monthly revenue
with MonthlyRevenue as (select date_format(treatment_date, '%Y-%m') as month, sum(cost) as monthly_revenue from treatments group by date_format(treatment_date, '%Y-%m')) select month, monthly_revenue, sum(monthly_revenue) over (order by month) as running_total from MonthlyRevenue order by month;