## Access Control Models

1. **RBAC (Role-Based Access Control)**  
   - Access based on **user roles** (e.g., Admin, Viewer).  
   - Permissions assigned to roles, not individuals.  

2. **ABAC (Attribute-Based Access Control)**  
   - Dynamic access based on **attributes** (user, resource, environment).  
   - Example: "Deny access if login location is outside the US."  

3. **ReBAC (Relationship-Based Access Control)**  
   - Access based on **relationships** (e.g., file owner, team member).  
   - Common in collaboration tools (e.g., Google Drive sharing).  

4. **PBAC (Policy-Based Access Control)**  
   - Governed by **centralized policies** (combines RBAC/ABAC/ReBAC).  
   - Uses policy engines like XACML.  

5. **DAC (Discretionary Access Control)**  
   - Owners manually grant access (e.g., file permissions).  
   - Example: Unix `chmod` commands.  

6. **MAC (Mandatory Access Control)**  
   - Strict, **label-based** access (e.g., Top Secret, Confidential).  
   - Used in military/government (e.g., SELinux).  

7. **CBAC (Context-Based Access Control)**  
   - Extends ABAC with **real-time context** (time, location, device).  
   - Example: "Block access outside business hours."  

8. **OrBAC (Organization-Based Access Control)**  
   - Rules based on **organizational roles/activities**.  
   - Example: "Doctors access records only during shifts."  

9. **GBAC (Graph-Based Access Control)**  
   - Formalized **relationship graphs** (e.g., social networks).  

10. **TBAC (Task-Based Access Control)**  
    - Permissions tied to **workflow stages** (e.g., loan approval).  

11. **ZBAC (Zone-Based Access Control)**  
    - Access based on **physical/logical zones** (e.g., network segments).  

