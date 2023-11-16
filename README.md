# Arc-Azure-Portal-Dashboards
This is a collection of Arc Dashboards & Scripts designed to leverage the Azure Resource Graph metadata captured as part of an Arc roll out.  These Azure Dashboards can be deployed as JSON files to your Azure Tenant and can be saved a private or publicly shared resources.

This will be an evolving set of Dashboards and resources all designed to provide a summary "one stop shop" view of Azure Arc connected VMs and Arc enabled SQL Servers.  Please note some of these dashboards use custom tagging to track distribution of Arc resources - the section at the end of this readme walks through some of the scripts included on this Repo that help with bulk application of Tags to VMs and SQL Instances.

Current dashboards on the repo include:

## ARC - Rollout Progress Tracker
<img src="img/Arc Progress.png">
(Note: may take some time to run on large Arc enabled estates)
Collects together a number of metrics and views to track Arc rollout progess and to pick up on any gaps that may exist, for example the number of VMs where SQL Server has been discovered vs the number of VMs that actually have the SQL Server Arc Agent installed.  Final Tiles provide detail queries for all Servers and all SQL Server instances, these can be downloaded as CSVs for further analysis


## ARC - Unified Server Inventory


# Apply Tag Script

