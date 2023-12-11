# Arc-Azure-Portal-Dashboards
This is a collection of Arc Dashboards & Scripts designed to leverage the Azure Resource Graph metadata captured as part of an Arc roll out.  These Azure Dashboards can be deployed as JSON files to your Azure Tenant and can be saved a private or publicly shared resources.

This will be an evolving set of Dashboards and resources all designed to provide a summary "one stop shop" view of Azure Arc connected VMs and Arc enabled SQL Servers.  Please note some of these dashboards use custom tagging to track distribution of Arc resources - the section at the end of this readme walks through some of the scripts included on this Repo that help with bulk application of Tags to VMs and SQL Instances.

## Overall objectives & purpose of these Dashboards
[Azure Arc](https://azure.microsoft.com/en-gb/products/azure-arc/) is one of the key technologies in Microsoft's Hybrid Cloud offerng. In essence it enables organisations to extend their Azure control plane into on premise or 3rd party cloud environments, providing managagement and PaaS like services to these deployments.  Azure Arc has several [benefits](https://learn.microsoft.com/en-us/azure/azure-arc/overview#key-features-and-benefits) however one key result of an Arc deployment is that key metadata (Machine name, installed Windows version, SQL Server deployemnts etc) is imported into the [Azure Resource Graph](https://learn.microsoft.com/en-us/azure/governance/resource-graph/overview)

Azure also provides the ability to create simple, [shared dashboards](https://learn.microsoft.com/en-us/azure/azure-portal/azure-portal-dashboards) which can expose this Azure Resource Graph Metadata.  Therefore the following dashboards have been put together to provide not only useful views across the Arc estate but also to act as a demonstration of what is possible. Each tile in the dashboard contains a seperate Azure Resource Graph query and by clicking on the visualisation this underlying query can be exposed.

## Azure Arc deployment for Windows, Linux & SQL Server  - a brief overview
(Please note the scope of Arc is evolving and expanding - for example Azure Arc can be used to manage on premise Kubernetes Clusters - however here we will focus on Windows & Linux deployments) Azure Arc can be deployed on a per server basis or at scale using various methods.  Typically on a per server basis the following will happen:
* Windows or Linux Arc Agent is installed and this lights up that server in Arc
* The Server is checked to see if SQL Server is running
* If SQL Server is present the SQL Server Agent is installed as an extension to the Arc Agent
* SQL Server Instances, their underlying databases and attributes of each are loaded into the Azure Resource Graph

## Installing the Dashboards
Each Dashboard is simply a JSON file.  Installing a new dashbaord is however a little counterintuitive as you have to be in an existing (or new) Dashoard to upload a new one  
* Open the "Dashboards" folder in this repo and download your selected dashboard JSON document
* Log on to the Azure Portal
* Click on "Dashboard" from the Azure Portal Menu
* Click on "Create"
* Select "Custom Dashboard" - when prompted to customise click on "Cancel"
* Now select "Upload" and upload your selected JSON Document

**Please note** however that it will by default be created as a "Private" Dashboard meaning only you will be able to see it.  To make it available to your colleagues you can hit the "Share" button which will publish it to a shared dashboard area or a named resource group. 

# Current Dashboards
There are a range of dashboards which give different overviews and slices ofthe underlying Metadata - the overall the objective is to give an overview of some aspect of the Arc deployment
Current dashboards on the repo include:

## ARC - Rollout Progress Tracker
<img src="img/Arc Progress.png">
(Note: may take some time to run on large Arc enabled estates)
Collects together a number of metrics and views to track Arc rollout progress and to pick up on any gaps that may exist.  Arc deployments are reasonably straightforward however theer can be occasions when Servers are not fully discovered or connected to Arc.  This dashboard is intended as a tracker during that deployment and includes metrics and visualisations such as:

* Total number of Servers (and Windows Servers) onboarded to Arc and how many are currently connected
* Total number of SQL Servers discovered, and how many of those are Enterprise or Standard Edition
* Visualisations showing the Windows Agent Status and SQL Server Agent Status breakdown (highlighting any gaps which may need to be addressed)
* Servers onboarded per subscription (typically there will be a Target value for onboarding Servers to Arc and this may be broken down by subscription)
* Donut charts of "Servers by OS" and "SQL Server by Version" showing the distribution of Windows and SQL Server Versions across the estate
There are also several detail queries for all Servers and all SQL Server instances, these can be downloaded as CSVs for further analysis



## ARC - Unified Server Inventory
<img src="img/ArcServerInventory.png">
Displays a full inventory of all Servers (Windows & Linux) registered to Arc.  Includes breakdowns by OS, OS Type (Standard and Data Center) and other Metrics



## ARC - Unified SQL Server Inventory
<img src="img/ArcSQLServer.png">
Similar to the above this dashboard tracks key metrics for all SQL Server Instances & their attached databases



## ARC- Estate Profile
<img src="img/ArcEstateProfile.png">
Useful for larger and more complex estates this dashboard is wider than the previous ones in order to accommodate estates with very diverse Operating Systems and Versions.  It also includes some key metrics such as the # of Windows 2012, SQL Server 2012 and SQL Server 2014 instances on Arc



## ARC- ESU Tracker
<img src="img/ArcESUTracker.png">
Many organisations have a need to implement Extended Security Updates (ESUs) on their estates as Windows and SQL Server go End of Life.  A key benefit of Azure Arc is the ability to implement ESUs on a PAYG monthly basis.  This dashboard enables the tracking of both Windows and SQL Server 2012 ESU assignments, as well as giving a heads up on SQL Server 2014 (which will go End of Life in July 2024) 


# Apply Tag Script
One of the most useful features once Azure Arc is deployed is Tagging of resources.  Any VM or SQL Server added to Arc is also automatically added to the Azure Resource Graph and as such can be treated as an Azure resource (in fact the dashboards above function by running queries against the Azure Resource Graph, if you click on any of the tiles you can see the underlying Kusto Query Language (KQL) Query being used to return results.)

Tags can be used to group resources together by for example Business Unit or Datacenter.  However, applying tags to several hundred resources can become laborious.  Therefore as part of these repo we've included a bulk tagging capability which can take as input a CSV of VMs or SQL Server Instances alongside their associated tags.



## Applying Tags to Arc resources

### Step 1 - prepare the CSV
A simplified example of an input CSV is shown at scripts/ApplyTag/AzureArc.csv.  
<img src="img/SampleCSV.png">
The CSV can contain additional columns however the script below ignores everything except:

* Name - the name of the resource to be tagged
* Type - VM or SQLInstance (no other resources are recognized at this time)
* ResourceGroup - The Azure Resource Group used to host the VM or Instance
* TAG_ Columns - These are the actual Tag values to be applied to the named resource

The script will look for any columns with the "TAG_" prefix, remove the prefix and will then create a Tag with whatever follows the prefix (so "TAG_BusinessUnit" becomes "BusinessUnit").

It is possible to create the CSV from scratch however we've also included two Resource Graph Queries:

* scripts/ApplyTag/Tagging - VM Instances.txt - can be used to download a CSV which lists all VMs
* scripts/ApplyTag/Tagging - SQL Instances.txt - similar to the above this can be used to download a CSV of all SQL Instances

Both Queries include several attributes to make it easier to identify the VM or SQL Instance, as mentioned these are ignored by the script.  The queries also include 3 empty columns to indicate how the tagging columns can be set up.

**Please Note:** The queries return all resources across all subscriptions however currently the tagging script operates at subscription level (subscription name is passed as a parameter).  You will need to separate out the CSV into 1 CSV per subscription to be processed.

The Tags can represent any useful grouping, some of the dashboards above assume the following tags are in place however it's very straightforward to edit the underlying queries & tiles to change to your own tags.

* BusinessUnit - owning Business Domain for the Server
* Location - On premise, on AWS or on GCP (Azure Arc operates across 3rd party clouds or on premise estates)
* Application - owning Application for the resource
* DataCenter - hosting data center

### Step 2 - running the script with your selected CSV


*Make sure you have Azure powershell module installed as prerequisite. To install Azure Powershell you can follow https://learn.microsoft.com/en-us/powershell/azure/install-azure-powershell?view=azps-10.4.1*

#### Login to Azure

```azurepowershell
Login-AzAccount 
```

Provide your Azure Credentials to login to Azure.

#### Select the Azure Subscription

Note your subscription id where you have your Azure ARC resources deployed and run the command below.

```azurepowershell
Select-AzSubscription -Subscription <"subscription id">  
```

#### Run the Script 

Run the script in the path scripts/ApplyTag/Apply-AzTag.ps1 and provide the path of CSV created in **Step 1**.

```azurepowershell
Apply-AzTag.ps1 -Path ./scripts/ApplyTag/AzureArc.csv
```






