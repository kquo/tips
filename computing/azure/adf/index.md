# Azure Data Factory (ADF)

- Definition: A cloud-based data integration service THAT 
    orchestrates data movement and transformation BETWEEN
    direct data sources <and> compute resources
- How does it work?
    Connect and collect
    Transform and enrich 
    CI/CD publish
    Monitor and alerts
- Most common "data integration pattern" = ETL (Extract/Transform/Load)
  - ADF has code-free ETL as a service
  - Option to do hard-coded transformation using Azure compute
  - Mapping data flow provide a UI-wizard to simplify your pipeline setup (5 aspects)
      1. Ingest data 
      2. Control flow
      3. Data flow
      4. Schedule ops
      5. Monitor ops  
- Components:
    Pipelines
    Activities
    Datasets
    Linked Services
    Dataflows
    Integration Runtimes
- Key terms:
    Control flow
    Pipeline run
    Triggers
    Parameters
    Variables
- PIPELINES: A logical grouping of ACTIVITIES that perform one unit of work 
  - ADF can have one of more pipelines
- ACTIVITIES: Represent a single "processing step" in the pipeline
  - Three (3) types of activities supported by ADF:
    - Data movement
    - Data transformation
    - Control
- DATASETS: Represent data structure giving selected view into data store
  - Points to the specific data SUBSET to use in activity
  - For input and output
- LINKED SERVICES (?)
- Mapping DATAFLOWS: 
  - Two (2) uses:
    - Represent data source (for INGEST)
    - Represent compute resource (for TRANSFORM)
  - Represent connection information to link ADF to external services
  - Works closely with datasets: This specifies HOW to connedt & datasets defines WHAT data looks like
- INTEGRATION RUNTIMES (IR):
  - Compute infrastructure used by ADF to provide FULLY MANAGED:
      1. Dataflows
      2. Data movements
      3. Activity dispatch
      4. SSIS Package Execution
  - Automatically manages Spart clusters
  - Three (3) IR types:
      1. Azure SSIS (SQL Server Integration Services) package execution (public or private)
      2. Self hosted; Activity dispatch & Data movements (public or private)
      3. Azure; Activity dispatch & Data movements & Dataflows (public or private)
  - Hybrid solution, depending on your networking needs

## References
- Microsoft doc: <https://docs.microsoft.com/en-us/azure/data-factory/introduction>
- Microsoft diagram:  <https://docs.microsoft.com/en-us/azure/data-factory/media/introduction/data-factory-visual-guide.png>

## Diagram
![ADF](https://docs.microsoft.com/en-us/azure/data-factory/media/introduction/data-factory-visual-guide.png)
