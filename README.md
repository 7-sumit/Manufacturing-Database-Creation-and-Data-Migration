# Manufacturing-Database-Creation-and-Data-Migration
## Problem Statement
We are required to design and build a robust, well-structured relational database system that captures all core functionalities of our manufacturing plant. We will need to analyze our current Excel-based data to define the necessary tables and relationships. Migrate all existing to ensure data integrity and consistency

Problems that need to be resolved in Database Design
1. Lack of Unique Identifiers
Current Issue: We have no guaranteed unique IDs for raw material batches, suppliers, machines, production orders, or individual components. This makes it difficult to trace a specific component back to its origin.
2. Disconnected Relationships
Current Issue: In Excel, a production order might list a machine and raw materials, but there is no enforceable link to a valid machine in our asset list or an actual batch of material in inventory. This leads to scheduling work on machines that are down for maintenance or using incorrect material grades.
3. Invalid or Ambiguous Data Entries
Current Issue: Our data suffers from inconsistencies, such as material grades being entered as "SS-304" in one row  and "Stainless 304" in another, measurement metrics are Kg for now and KG for some rows.

## Data Description
⦁	SupplierID, SupplierName: Identifies the company that provides the raw materials.
⦁	RawMaterialBatchID: A unique identifier for a specific delivery of a raw material.
⦁	MaterialName, MaterialGrade: Describes the type and quality of the raw material (e.g., "PVC Pellets", "Type 1").
⦁	InitialQuantity, Unit: The amount of material received in a specific batch and its unit of measure (e.g., "KG", "m", "pcs").
⦁	ReceiveDate: The date the raw material batch was received.
⦁	MachineID, MachineName, MachineType: Identifies the specific piece of equipment used for a production run. The MachineName often contains a plant identifier (e.g., "P1-...").
⦁	LastMaintenanceDate: The last recorded service date for the machine.
⦁	CustomerOrderID, CustomerName: Identifies the external customer order that triggered the production.
⦁	OrderDate: The date the customer placed the order.
⦁	ProductionOrderID: This is the central "work order" or job number. (P1-25-1001, P1_25_1002, 1005)  P1, P2 indicates the plant that produces the order.
⦁	ComponentToProduce, QuantityToProduce: Specifies what product is being made and in what quantity for this specific job.
⦁	ScheduledStart, ScheduledEnd: The planned start and end times for the production job.
⦁	Status: The current state of the production order (e.g., "Scheduled", "Completed", "On Hold").
⦁	MaterialUsedBatchID, QuantityUsed: Records which batch of raw material was consumed for the production order and how much was used.
⦁	QualityCheckID: An identifier for the quality inspection.
⦁	CheckTimestamp, Result, InspectorName: Records when the quality check was performed, whether the component "Passed" or "Failed", and who performed the inspection.

## Project Summary
1. Manufacturing Data Cleaning and Validation
Performed comprehensive data cleaning on raw manufacturing datasets using SQL.
Identified and removed data abnormalities such as duplicate records, missing values, inconsistent formats, and invalid entries.
Applied data validation techniques to improve data accuracy, consistency, and reliability for downstream analysis and reporting.
2. Database Design and Normalization
Designed and developed a structured relational database for manufacturing operations.
Imported and migrated data from multiple CSV files into SQL database tables.
Applied database normalization techniques (1NF, 2NF, and 3NF) to eliminate data redundancy and improve data integrity.
Created separate tables for entities such as production orders, inventory, materials, quality checks, and suppliers based on normalization rules.
3. Data Modeling and Relationship Establishment
Analyzed existing datasets and identified issues with provided unique identifiers, including duplicate and inconsistent values.
Generated new unique identifier columns to ensure proper entity identification and record tracking.
Established relationships between tables using Primary Keys and Foreign Keys.
Developed an efficient relational schema that enabled seamless data retrieval and maintained referential integrity across the database.
4. Inventory Monitoring Automation using SQL Triggers
Designed and implemented database triggers to monitor material inventory levels automatically.
Configured threshold-based alert mechanisms to notify stakeholders whenever inventory quantities fell below predefined limits.
Enabled proactive inventory management, helping reduce the risk of production delays caused by material shortages.
5. Production Quality Control Automation
Developed automated SQL triggers to support quality assurance processes.
Created logic to update production records automatically when quality inspections failed.
Implemented a trigger that changes the production status to 'Rework Required' whenever an order fails standard quality testing criteria.
Improved traceability and ensured immediate visibility of quality-related issues within the production workflow.
Database Integrity and Business Rule Enforcement
Implemented constraints, relationships, and trigger-based validations to enforce manufacturing business rules.
Ensured consistency between inventory, production, and quality control data.
Reduced manual intervention by automating critical operational processes within the database.

## Project Outcome
1. Successfully transformed raw manufacturing data into a clean, normalized, and relational database structure.
2. Enhanced data quality, integrity, and operational efficiency through SQL-based automation.
3. Enabled real-time inventory monitoring and automated quality control status management.
4. Created a scalable and maintainable database solution to support manufacturing decision-making and reporting requirements.





