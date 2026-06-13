select * from ABC_10000

--Creating a copy of table
select * into abc_backup from ABC_10000;

drop table abc_backup

select distinct supplierid from abc_backup

--Cleaning 'suppliername' column
update abc_backup
set SupplierName = 
trim(replace(replace(replace(replace(replace(suppliername,'GlobalMetals','Global Metals'),'PlasticPro Inc.','PlasticPro'),'Copper Co.','CopperCo'),'SteelCorp','Steel Corp'),'AluWorks','Alu Works'))


--Cleaning 'InitialQuantity' column
update abc_backup
set InitialQuantity = 
trim(replace(replace(InitialQuantity,'$',''),',',''))


--Cleaning 'Unit' column
update abc_backup
set Unit = 
trim(replace(replace(replace(Unit,'KG','kg'),'meter','m'),'ms','m'))




--Converting all string date columns into date data type

--'ReceiveDate' column
update abc_backup
set ReceiveDate = 
try_convert(date,ReceiveDate,105)

--'LastMaintenanceDate' column
update abc_backup
set LastMaintenanceDate = 
coalesce(
try_convert(date,LastMaintenanceDate,105),
try_convert(date,LastMaintenanceDate,101)
)

--'Order date' column
update abc_backup
set OrderDate = 
coalesce(
       try_convert(datetime,OrderDate,105),
	   try_convert(datetime,OrderDate,110)
	   )

--'ScheduledStart' column
update abc_backup
set ScheduledStart = 
try_convert(datetime,ScheduledStart,105)


--'ScheduledEnd' column
update abc_backup
set ScheduledEnd =
try_convert(datetime,ScheduledEnd,105)


--'CheckTimestamp' column
update abc_backup
set CheckTimestamp = 
try_convert(datetime,CheckTimestamp,105)


--Cleaning ID columns

--'RawMaterialBatchID' column
update abc_backup
set RawMaterialBatchID = 
left(RawMaterialBatchID,7)


--MachineName

--Creating new column 'PlantID' from machineName
alter table abc_backup
add PlantID VARCHAR(2);

update abc_backup
set PlantID = 
left(trim(MachineName),2)


--'MachineID' column
update abc_backup
set MachineName = 
trim(replace(replace(MachineName,'P1-',''),'P2-',''))


--'ProductionOrderID' column
update abc_backup
set ProductionOrderID =
right(ProductionOrderID,4)


--Final Cleaned Data
select * from abc_backup

--Creating seperate table for cleaneed data
select * into cleaned_data from abc_backup


