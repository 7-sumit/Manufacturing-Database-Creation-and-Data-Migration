select * from cleaned_data

-- Creating tables and normalizing cleaned_data

--Supplier table
Create table supplier(
supplier_id int primary key identity(1,1),
supplier_code nvarchar(50) not null unique,
supplier_name nvarchar(50) not null
)

--Customers table
Create table customers(
customer_id int primary key identity(1,1),
customer_code nvarchar(50) not null unique,
customer_name nvarchar(50) not null
)

--Raw materials table
Create table rawmaterials(
   material_id INT PRIMARY KEY IDENTITY(1,1),
   material_name NVARCHAR(100) NOT NULL,
   material_grade  NVARCHAR(50),
   CONSTRAINT UNIQUE_MATERIAL UNIQUE(material_name, material_grade)
   )

--Machines table
Create table machines(
   machine_id INT PRIMARY KEY IDENTITY(1,1),
   machine_code  NVARCHAR(50) NOT NULL UNIQUE,
   machine_name NVARCHAR(50) NOT NULL,
   machine_type NVARCHAR(50), 
   plant_id NVARCHAR(10) NOT NULL,
   last_maintaince_date DATE NULL
   )

--Production table
Create table productionorders(
  production_id INT PRIMARY KEY IDENTITY(1,1),
  production_code NVARCHAR(20) NOT NULL UNIQUE,
  customer_id INT NOT NULL,
  component_to_produce  NVARCHAR(255) NOT NULL,
  quantity_to_produce  INT NOT NULL, 
  order_date DATETIME NOT NULL,
  scheduled_start_date DATETIME NOT NULL,
  scheduled_end_date DATETIME NOT NULL,
  [status]  NVARCHAR(50) NOT NULL,
  assigned_machine_id INT NULL , 
  plant_id INT NOT NULL,

  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (assigned_machine_id) REFERENCES machines(machine_id),
  CONSTRAINT CHK_SCHEDULESEQUENCE CHECK (scheduled_end_date >= scheduled_start_date)
  )

  --Material Inventory table
  CREATE TABLE materialinventory(
  batch_id INT PRIMARY KEY IDENTITY(1,1),
  original_batch_id NVARCHAR(50) UNIQUE,
  material_id INT NOT NULL,
  supplier_id INT NOT NULL,
  received_date  DATE NOT NULL,
  initial_qunatity DECIMAL(10,2) NOT NULL,
  remaining_quantity DECIMAL(10,2) NOT NULL,
  unit NVARCHAR(10) NOT NULL,

  FOREIGN KEY (material_id) REFERENCES rawmaterials(material_id),
  FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id))


--Production Material Usage table
CREATE TABLE production_material_usage(
	 usage_id int primary key identity(1,1),
	 production_id int not null,
	 batch_id int not null, 
	 quantity_used decimal(10,2) not null,

	 FOREIGN KEY (production_id) references productionorders(production_id),
	 Foreign key (batch_id) references materialinventory(batch_id)
	 )

--Employees table
create table employees(
   employee_id int primary key identity(1,1),
   emp_name Nvarchar(100) not null ,
   [role] nvarchar(50) not null
   )

--Quality Check table
Create table qualitychecks(
    quality_check_id int primary key identity(1,1),
	original_quality_check_id nvarchar(50),
	production_id int not null,
	inspector_id int not null,
	check_time_stamp Datetime not null,
	results  Nvarchar(10) ,

	foreign key (production_id) references productionorders(production_id),

	foreign key (inspector_id) references employees(employee_id)
)


--Inserting data into created tables

--Supplier Table
--Dropping column supplier code as values are not distinct for particular supplier name
ALTER TABLE supplier
DROP CONSTRAINT UQ__supplier__A82CE469FD258778

ALTER TABLE supplier    
DROP COLUMN supplier_code

insert into supplier(supplier_name)
select distinct suppliername from cleaned_data where suppliername is not null

select * from supplier


--Customers table
--Dropping column customer code as values are not distinct for particular customer name
ALTER TABLE customers
DROP CONSTRAINT UQ__customer__6A9E4CB710371711

ALTER TABLE customers    
DROP COLUMN customer_code

insert into customers(customer_name)
select distinct CustomerName from cleaned_data


select * from customers


--Raw materials table
--Inserting unique values of material name and material grade in table
insert into rawmaterials(material_name,material_grade)
select distinct MaterialName,MaterialGrade from cleaned_data

select * from rawmaterials

--Machine table
--Dropping column machine code as values are not distinct for particular machine name
ALTER TABLE machines
DROP CONSTRAINT UQ__machines__FDCF4D73FD023C67

ALTER TABLE machines    
DROP COLUMN machine_code

insert into machines(machine_name,machine_type,plant_id,last_maintaince_date)
select MachineName,MachineType,PlantID,max(try_convert(date,LastMaintenanceDate)) from cleaned_data 
group by MachineName,MachineType,PlantID

select * from machines


--Material Inventory table
alter table materialinventory
drop constraint UQ__material__F8321935EC423C2C

alter table materialinventory
alter column remaining_quantity decimal(9,2) null

delete materialinventory

dbcc  checkident('MATERIALINVENTORY', reseed, 0)

--Entering data in material inventory
insert into materialinventory(original_batch_id,material_id,supplier_id,received_date,initial_qunatity,unit)
select cd.RawMaterialBatchID,rm.material_id,s.supplier_id,try_convert(date,cd.ReceiveDate),cast(cast(cd.InitialQuantity as float) as decimal(10,2)),cd.Unit 
from cleaned_data cd
join rawmaterials rm
on cd.MaterialName = rm.material_name and cd.MaterialGrade = rm.material_grade
join supplier s
on cd.SupplierName = s.supplier_name
order by cd.RawMaterialBatchID


select * from materialinventory


--Productionorders table
--Dropping column production code as values are not distinct for particular order given by customer
alter table productionorders
drop constraint UQ__producti__7B8A0A68A885B6D9

alter table productionorders
drop column production_code

alter table productionorders
alter column plant_id nvarchar(2) not null

delete productionorders

dbcc  checkident('productionorders', reseed, 0)


--Inserting data into production orders
with cleaning_orders as (
select c.customer_id,cd.ComponentToProduce,cast(ceiling(cast(cd.QuantityToProduce as decimal(10,2)))as int) as QuantityToProduce,try_convert(datetime,cd.OrderDate) as OrderDate ,try_convert(datetime,cd.ScheduledStart) as ScheduledStart,try_convert(datetime,cd.ScheduledEnd) as ScheduledEnd,cd.Status,m.machine_id,m.plant_id
from cleaned_data cd
join customers c
on cd.CustomerName = c.customer_name
join machines m
on cd.MachineName = m.machine_name and cd.MachineType = m.machine_type and cd.PlantID = m.plant_id)


insert into productionorders(customer_id,component_to_produce,quantity_to_produce,order_date,scheduled_start_date,scheduled_end_date,[status],assigned_machine_id,plant_id)
select * from cleaning_orders
where OrderDate <= ScheduledStart and ScheduledStart <= ScheduledEnd

select * from productionorders 


--Production Material Usage table

alter table production_material_usage
alter column quantity_used decimal(10,2)

--Inserting data into production_material_usage table
insert into production_material_usage(production_id,batch_id,quantity_used)
select o.production_id,m.batch_id,cast(cast(cd.QuantityUsed as float) as decimal(10,2)) as QuantityUsed
from cleaned_data cd
join productionorders o
on cd.ComponentToProduce = o.component_to_produce and cd.[Status] = o.[status] and cd.OrderDate  = o.order_date and cd.ScheduledStart = o.scheduled_start_date and cd.ScheduledEnd = o.scheduled_end_date
join materialinventory m
on cd.MaterialUsedBatchID = m.original_batch_id and cd.ReceiveDate = m.received_date and cd.Unit = m.unit


select * from production_material_usage



--Updating 'remaining_quantity' of material inventory
update m
set m.remaining_quantity = coalesce((m.initial_qunatity - mu.quantity_used),m.initial_qunatity)
from materialinventory m
left join production_material_usage mu
on m.batch_id = mu.batch_id

--Replacing negative values with 0
begin transaction
update materialinventory
set remaining_quantity = 0
where remaining_quantity <=0

--Replacing rows with valid values where quantity used was greater than initial quantity 
begin transaction
update mu
set mu.quantity_used = m.initial_qunatity
from
production_material_usage mu
join materialinventory m
on mu.batch_id = m.batch_id
where m.remaining_quantity = 0

commit


--Quality Check Table

--Dropping employess table as employee information is inaccurate and difficult to clean
alter table qualitychecks
drop constraint FK__qualitych__inspe__74AE54BC

alter table qualitychecks
drop column inspector_id

drop table employees

alter table qualitychecks
alter column check_time_stamp Datetime

dbcc  checkident('qualitychecks', reseed, 0)


--Inserting data into quality checks table
insert into qualitychecks(original_quality_check_id,production_id,check_time_stamp,results)
select cd.QualityCheckID, o.production_id, try_convert(datetime,cd.CheckTimestamp) as CheckTimestamp,cd.Result
from cleaned_data cd
join productionorders o
on cd.ComponentToProduce = o.component_to_produce and cd.OrderDate = o.order_date and cd.ScheduledStart = o.scheduled_start_date and cd.ScheduledEnd = o.scheduled_end_date and cd.[Status] = o.[status]
where cd.QualityCheckID is not null


select * from qualitychecks


----------------------------END--------------------------------

--Creating Triggers

--1. Creating trigger on Quality Checks table to automatically update the production id order status in production orders table 
--to 'Rework Required' when quality check for a particular production id failes 

select * from qualitychecks

select * from productionorders

update productionorders
set [status] = 'Rework Required'
where production_id in 
(select production_id from qualitychecks
where results = 'Failed')

Create or alter trigger update_product_status_on_fail
on qualitychecks
after insert
as
begin
	update o
	set o.[status] = 'Rework Required'
	from productionorders o
	join inserted i
	on i.production_id = o.production_id
	where i.results = 'Failed'
end


--2.Creating trigger on MaterialInventory table to automatically send a alert in MaterialLowStockLog table when the material stocks 
--decreases below a certain threshold to replenesh the supplies

CREATE TABLE MaterialLowStockLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    MaterialID INT NOT NULL,
    MaterialName NVARCHAR(100),
    MaterialGrade NVARCHAR(50),
    AlertTriggerQuantity DECIMAL(10, 2), -- How much was left when triggered
    QuantityToOrder DECIMAL(10, 2),      -- The new calculated column
    AlertDate DATETIME DEFAULT GETDATE()
);

Create or alter trigger TRG_LOWSTOCK
on materialinventory
after insert,update
as
begin
	insert into MaterialLowStockLog(MaterialID,MaterialName,MaterialGrade,AlertTriggerQuantity,QuantityToOrder)
	select i.material_id,m.material_name,m.material_grade,i.remaining_quantity,(4000-i.remaining_quantity) 
	from inserted i
	join rawmaterials m
	on i.material_id = m.material_id
	where i.remaining_quantity < 500
end

